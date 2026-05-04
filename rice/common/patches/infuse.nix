############################################################################
#
# version 2.4
#
# `infuse.nix` is a "deep" version of both `.override` and `.overrideAttrs` which
# generalizes both `lib.pipe` and `recursiveUpdate`.  It can be used as a leaner,
# untyped alternative to `lib.modules`.  If you want dynamic typechecking, it
# works well with [yants](https://code.tvl.fyi/tree/nix/yants/README.md).
#
# Copyright (c) 2024 amjoseph F0B74D717CDE8412A3E0D4D5F29AC8080DA8E1E0
# You may copy and modify this subject to the (MIT) license a the end
# of this file.
#
#   canonical source: https://codeberg.org/amjoseph/infuse.nix
#   questions:        #six/hackint (be patient, i am asynchronous)
#
#                        ****** VENDOR ME! ******
#
# This file is self-contained and has no dependencies other than <nixpkgs/lib>;
# you should copy it into your own project.  Or, you can also do this:
#
# let
#   infuse =
#     (import
#       (builtins.fetchGit {
#         url  = "https://codeberg.org/amjoseph/infuse.nix";
#         name = "infuse.nix";
#         ref  = "refs/tags/v2.4";
#         rev  = "";
#         shallow = true;
#         publicKey = "F0B74D717CDE8412A3E0D4D5F29AC8080DA8E1E0";
#         keytype = "pgp-ed25519";
#       }) { inherit lib; }).v1.infuse;
# in
#   ...
#
############################################################################
#
# Vocabulary
#
# The preferred English translation of the nix expression `infuse target inf` is
# "infuse `target` with `inf`".  This matches the argument order, making it
# easier to remember.  Another way to remember the argument order is to keep in
# mind that `infuse` can always be used in place of `lib.pipe`.
#
# Specification
#
# The following is a specification, not an introduction.  See README.md for more
# details or TUTORIAL.md for an introduction.  The algebraic laws, as well as
# some of the non-obvious consequences of the specification are documented in
# tests/default.nix, along with test cases which demonstrate them.
#
# A *desugared infusion* is defined (inductively) as a function or a non-empty
# attrset whose attrvalues are desugared infusions.
#
# The result of *infusing* a target (which may not exist) with a desugared
# infusion is defined inductively based on the type of the infusion:
#
# - for a function,
#   - if the target exists, the result is the function applied to the target
#   - if the target does not exist, the function is applied to
#     `infusion.__default_argument or missing-attribute-marker`.  Note:
#     `missing-attribute-marker` is not publicly exposed.
# - for an attrset,
#   - if the target is a derivation: the result is an error
#   - if the target is not an attrset: the result is an error
#   - if the target is a non-derivation attrset: the result is the target
#     updated (//) with an attrset formed by infusing into each target attrvalue
#     the infusion attrvalue with the same name, if one exists.
#
# An important property of this encoding is that it is totally collision-free.
# There are no special attribute names or special values: desugared infusions
# can act upon any attrset, even attrsets with names like `__append` and values
# like `null` or `throw "fail"`.
#
# An *infusion* is defined the same way as a desugared infusion, except that:
#
#   - A sugared infusion may be an empty attrset `{}`
#   - A sugared infusion may be a list of sugared infusions.
#   - If a sugared infusion is an attrset and any of its attrnames begin with
#     the two-character prefix "__" (double underscore), then:
#     - *all* of its attrnames must begin with "__" and
#     - its attrvalues may be *any* Nix value
#
# In other words, a sugared infusion may not mix __-prefixed attributes and
# non-__-prefixed attributes in the same attrset.
#
# To *desugar* an infusion, do the following recursively, depth-first:
#
#   - To desugar an empty attrset `{}`, remove it.
#   - To desugar a list, desugar its elements, apply `flip-infuse-desugared` to
#     each element to create a function, and then apply `flip pipe` to the list
#     of functions into a single function.  The `__default_arguments` attribute
#     must be propagated from the head of the list.
#   - To desugar an attrset having names which begin with "__", apply the
#     attribute of `listToAttrs sugars` having the same name to it, and apply
#     the results to the target in the same order in which they occur in
#     the list `sugars`.
#
# The set of `sugars` is a parameter to this file and can be customized.  The
# default value currently has these attributes, which are applied in this order:
#
# __init      # assign a new value if none existed in the target; otherwise `throw`
# __default   # assign a new value only if none already existed in the target
# __assign    # assign a new value, ignoring the target value
#
# __underlay  # pre-extend an overlay by adding another one before it (see note)
# __overlay   # post-extend an overlay by adding another one after it (see note)
#
# __prepend   # prepend a string or list to the target value
# __append    # append a string or list to the target value
#
# __input     # invoke .override (see note)
# __output    # invoke .overrideAttrs (see note)
#
# __values    # `infuse target { __values = f; }` is the same as `infuse target (lib.mapAttrs (_: f))`
# __infuse    # `infuse target { __infuse = f; }` is the same as `infuse target f`
#
# Note: __underlay, __overlay, __input, and __output expect the sugared infusion
# attrvalue to be a function.  However it can also be an attrset; in that case
# the attrset is assumed to be a sugared infusion, and will be desugared and
# converted into a function:
#
# - for __input:                       `(   prev: infuse prev attrs)`
# - for __output __underlay __overlay: `(_: prev: infuse prev attrs)`
#
# There is no `__remove` because Nix attrsets are strict in their attrnames;
# deleting attribute names from an attrset tends to cause infinite recursion
# failures.  Consider using `__assign = null` instead.
#

{ lib ? import <nixpkgs/lib> { }
, sugars ? null  # see `default-sugars` below for explanation
, ...
}:
let

  ##############################################################################
  # Public API (versioned)

  v1 = {
    # the path-accepting forms are not public
    infuse = flip (flip-infuse [ ]);
    desugar = desugar [ ];
    infuse-desugared = flip (flip-infuse-desugared [ ]);
    optimize = optimize [ ];
    inherit default-sugars;
  };

  # Everything from here to the end of this file is internal implementation
  # details.

  inherit (builtins)
    typeOf length head attrValues intersectAttrs;
  inherit (lib)
    flip mapAttrs isFunction isAttrs isDerivation
    any all showAttrPath nameValuePair listToAttrs
    isList isString id flatten filter hasPrefix
    attrNames optionalString hasAttr;

  # This is a `throw`-tolerant version of toPretty, so that error diagnostics in
  # this file will print "<<throw>>" rather than triggering a cascading error.
  toPretty =
    args: val:
    let
      try = builtins.tryEval (lib.generators.toPretty args val);
    in
    if try.success
    then try.value
    else "<<throw>>";


  ##############################################################################
  # Utility+Helper functions

  # Like `isAttrs`, but returns `false` for attrsets with `__functor` attributes.
  # This ought to be in <nixpkgs/lib>.
  isNonFunctorAttrs = v: (isAttrs v) && !(isFunction v);

  # `lib.pipe` is too strict because it uses builtins.foldl' (there is a test
  # case in tests/default.nix that will fail if `flip pipe` is used instead).
  # This ought to be in <nixpkgs/lib>.
  flip-pipe-lazy =
    builtins.foldl' (f: g: x: g (f x)) id;

  # Error reporting, including attrpath at which the error occurred
  throw-error =
    { path ? null
    , func
    , msg
    }:
    let
      where = optionalString (path != null) "at path ${showAttrPath path}: ";
    in
    throw "infuse.${func}: ${where}${msg}";

  # like `builtin.map`, but for functions that take an additional `path`
  # argument.  Type: [String] -> ([String] -> a -> b) -> [a] -> [b]
  map-with-path =
    path: f: list:
    lib.imap0 (idx: v: f (path ++ [ "[${toString idx}]" ]) v) list;

  # see doc/design-notes-on-missing-attributes.md
  get-default-argument =
    path: infusion:
      infusion.__default_argument or
        (if isNonFunctorAttrs infusion
        then { }
        else if isList infusion
        then if length infusion != 0
        then get-default-argument path (head infusion)
        else missing-attribute-marker
        else missing-attribute-marker);

  # Replace any leafless attrsets anywhere within the infusion with `{}`
  # A leafless attrset is either `{}` or an attrset whose attrvalues are all
  # leafless attrsets.  See doc/design-notes-leafless-attrsets.md
  prune =
    path:
    infusion:
    if isList infusion
    then map-with-path path prune infusion
    else if !(isNonFunctorAttrs infusion)
    then infusion
    else
      let pruned = mapAttrs (k: v: prune (path ++ [ k ]) v) infusion;
      in if all (v: v == { }) (attrValues pruned)
      then { }
      else pruned;


  ##############################################################################
  # Desugared Infusion

  #
  # The `flip-infuse*` functions are defined in argument-reversed form to avoid
  # eta-expanding, which would turn a {__functor = ..., __default_argument =
  # ...} into a normal function.  The exported API is `flip flip-*` (see `v1`).
  #

  flip-infuse = path: infusion:
    flip-infuse-desugared path (desugar path infusion);

  flip-infuse-desugared = path: infusion:
    flip-infuse-desugared-pruned path (prune path infusion);

  flip-infuse-desugared-pruned =
    path: # attrpath relative to top-level call; only for error reporting
    infusion: # infusion to infuse upon the target attrset

    let
      throw-err = msg: throw-error {
        inherit path msg;
        func = "flip-infuse-desugared-pruned";
      };
    in

    if isFunction infusion
    then infusion

    else if isList infusion
    then flip-pipe-lazy (map-with-path path flip-infuse-desugared-pruned infusion)

    else if !(isAttrs infusion)
    then throw-err "desugared infusions must contain only functions, lists, and attrsets; found a ${typeOf infusion}"

    else

      target: # target attrset to be infused with the infusion
      # we float the `target:` lambda *inward* to encourage thunk-sharing

      if isDerivation target
      then throw-err "attempted to infuse to subattributes of a derivation (did you forget to use desugar?)"

      else if !(isAttrs target)
      then throw-err "attempted to infuse an attrset to a target of type ${typeOf target}"

      else
        target //
        (mapAttrs
          (k: v:
          flip-infuse-desugared-pruned (path ++ [ k ]) v
            (target.${k} or (get-default-argument path v)))
          infusion);


  ##############################################################################
  # Desugaring

  # This uses [@sternenseeman's research][1] on the semantics of Nix function
  # equality to create a special value which can never be (==)-equal to any
  # value created outside of this file.
  # [1]: https://code.tvl.fyi/tree/tvix/docs/src/value-pointer-equality.md
  missing-attribute-marker = [ [ (throw "the missing-attribute-marker was forced") ] ];

  # each of the __foo functions below takes its argument exactly as it appears
  # in the (sugared) infusion, and should return a *desugared* infusion.
  default-sugars =
    let

      # the identity overlay, lambda-lifted to avoid allocations
      identity-overlay = _: prev: prev;

      # `with-default default func` is the same as `func` -- except when applied to
      # the `missing-attribute-marker`; in that case it returns `func default`
      with-default =
        default: func:
        arg:
        if arg == missing-attribute-marker
        then func default
        else func arg;

      __init = path: value: prev:
        if prev == missing-attribute-marker
        then value
        else
          throw-error {
            inherit path;
            func = "desugar";
            msg = "infused a value to __init but attribute already existed, value=${toPretty {} prev}; maybe you meant to use __assign or __default?";
          };

      __default = _: value:
        with-default value id;

      __assign = _: value: _:
        value;

      __underlay = path: overlay:
        if isNonFunctorAttrs overlay then
          __underlay path (_: flip-infuse path overlay)
        else if isFunction overlay then
          with-default identity-overlay
            (old:
              assert isFunction old;
              lib.composeExtensions overlay old)
        else
          throw-error {
            inherit path;
            func = "prelay";
            msg = "applied to unsupported type: ${typeOf overlay}";
          };

      __overlay = path: overlay:
        if isNonFunctorAttrs overlay then
          __overlay path (_: flip-infuse path overlay)
        else if isFunction overlay then
          with-default identity-overlay
            (old:
              assert isFunction old;
              lib.composeExtensions old overlay)
        else
          throw-error {
            inherit path;
            func = "overlay";
            msg = "applied to unsupported type: ${typeOf overlay}";
          };

      __prepend = path: infusion:
        if isString infusion then
          with-default "" (string: assert isString string; infusion + string)
        else if isList infusion then
          with-default [ ] (list: assert isList list; infusion ++ list)
        else
          throw-error {
            inherit path;
            func = "prepend";
            msg = "applied to unsupported type: ${typeOf infusion}";
          };

      __append = path: infusion:
        if isString infusion then
          with-default "" (string: assert isString string; string + infusion)
        else if isList infusion then
          with-default [ ] (list: assert isList list; list ++ infusion)
        else
          throw-error {
            inherit path;
            func = "append";
            msg = "applied to unsupported type: ${typeOf infusion}";
          };

      __input = path: infusion:
        if isNonFunctorAttrs infusion
        then __input path (previousArgs: flip-infuse path infusion previousArgs)
        else if isFunction infusion
        then old:
          if old?override then old.override infusion
          else if isFunction old then arg: old (infusion arg)
          else
            throw-error {
              inherit path;
              func = "input";
              msg = "attempted to infuse a function to __input attribute of a ${typeOf infusion}";
            }
        else
          throw-error {
            inherit path;
            func = "input";
            msg = "infused an unsupported type to __input: ${typeOf infusion}";
          };

      __output = path: infusion:
        if isNonFunctorAttrs infusion
        then target: __output path (_: previousAttrs: flip-infuse path infusion previousAttrs) target
        else if isFunction infusion
        then target:
          if isFunction target then arg: infusion (target arg)
          else if isDerivation target && target?overrideAttrs
          then
            target.overrideAttrs
              (final: prev:
                let applied = infusion final; in
                if !(isFunction applied)
                then
                  throw-error
                    {
                      inherit path;
                      func = "output";
                      msg = "when infusing to drv.__output you must pass a *two*-argument curried function (i.e. `__output = finalAttrs: previousAttrs: ...`)";
                    } else applied prev)
          else
            throw-error {
              inherit path;
              func = "input";
              msg = "attempted to infuse to __output of an unsupported type: ${typeOf target}";
            }
        else
          throw-error {
            inherit path;
            func = "output";
            msg = "applied to unsupported type: ${typeOf infusion}";
          };

      __values = path: infusion:
        let
          infusion' = desugar (path ++ [ "__values" ]) infusion;
        in
        lib.mapAttrs (_: flip-infuse-desugared path infusion');

      __infuse = path: infusion:
        desugar path infusion;

    in
    [
      (nameValuePair "__init" __init)
      (nameValuePair "__default" __default)
      (nameValuePair "__assign" __assign)
      (nameValuePair "__underlay" __underlay)
      (nameValuePair "__overlay" __overlay)
      (nameValuePair "__prepend" __prepend)
      (nameValuePair "__append" __append)
      (nameValuePair "__input" __input)
      (nameValuePair "__output" __output)
      (nameValuePair "__values" __values)
      (nameValuePair "__infuse" __infuse)
    ];

  enabled-sugars =
    if sugars != null
    then sugars
    else default-sugars;

  sugar-map =
    listToAttrs enabled-sugars;

  sugar-list =
    map (n: n.name) enabled-sugars;

  desugar = path: infusion:
    if isFunction infusion then
      infusion
    else if (isList infusion) then
      map (desugar path) infusion
    else if !(isAttrs infusion) then
      throw-error
        {
          inherit path;
          func = "desugar";
          msg = "invalid type ${typeOf infusion}";
        }
    else if !(any (hasPrefix "__") (attrNames infusion)) then
      mapAttrs (k: v: desugar (path ++ [ k ]) v) infusion
    else if !(all (hasPrefix "__") (attrNames infusion)) then
      throw-error
        {
          inherit path;
          func = "desugar";
          msg = "mixing special (hasPrefix \"__\") and non-special attributes at the same path level is not (yet) supported";
        }
    else if (any (name: !(hasAttr name sugar-map)) (attrNames infusion)) then
      throw-error
        {
          inherit path;
          func = "desugar";
          msg = "infusion contains __-prefixed attrnames which are not in the sugar-map: ${filter (name: !(hasAttr sugar-map name)) (attrNames infusion)}";
        }
    else
      map
        (sugar-name:
          sugar-map.${sugar-name}
            (path ++ [ sugar-name ])
            infusion.${sugar-name})
        (filter (name: hasAttr name infusion) sugar-list);


  ##############################################################################
  # Optimizer

  # `infuse (infuse t a) b == compose-attrset-infusions a b` if both `a` and `b`
  # are attrsets.
  compose-attrset-infusions =
    a: b:
      assert isAttrs a;
      assert isAttrs b;
      (a // b)
      //
      mapAttrs
        (k: _:
        let
          composed = flatten [ a.${k} b.${k} ];
        in
        # uncommnent this line to trace optimizations
          #lib.warn "compose-attrset-infusions ${toPretty {} a} ${toPretty {} b} = ${toPretty {} composed}"
        composed
        )
        (intersectAttrs a b)
  ;

  # Flatten any nested lists, then merge any contiguous sequences of attrsets
  # within a list using the (//) operator.  This exploits the "distributive law
  # of `//` over `[]`
  optimize =
    path:
    infusion:

    if isNonFunctorAttrs infusion
    then mapAttrs (k: v: optimize (path ++ [ k ]) v) infusion

    else if !(isList infusion)
    then infusion

    else
      let

        # an "accumulator" -- consists of a list of infusions `list` followed by
        # an optional single attrset infusion `set`
        nul = { list = [ ]; set = null; };

        # collapses an accumulator into a single list-infusion
        collapse = acc: acc.list ++ lib.optionals (acc.set != null) [ acc.set ];

        op = acc: next:
          if isNonFunctorAttrs next
          then {
            inherit (acc) list;
            set =
              if acc.set == null
              then next
              else compose-attrset-infusions acc.set next;
          } else {
            list = (collapse acc) ++ [ next ];
            set = null;
          };

        merge = list: collapse (lib.foldl op nul list);
      in
      map-with-path path optimize (merge (flatten infusion));

in
{
  inherit v1;
}


############################################################################
#
# LICENSE
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
