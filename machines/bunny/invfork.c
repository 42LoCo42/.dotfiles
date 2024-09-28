#include <err.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char** argv) {
	for(int i = 0; i < argc; i++) {
		// "--" is parent-child separator
		if(strcmp(argv[i], "--") == 0) {
			switch(fork()) {
			case -1: // error
				err(1, "could not fork");

			case 0: // child
				execvp(argv[i + 1], &argv[i + 1]);
				err(1, "child: could not exec");

			default:            // parent
				argv[i] = NULL; // terminate parent command line
				execvp(argv[1], &argv[1]);
				err(1, "parent: could not exec");
			}
		}
	}
}
