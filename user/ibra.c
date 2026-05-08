#include "kernel/types.h"
#include "user/user.h"

int main(){
    int fds[2];
    char buf[100];
    int n;
    int pid;

    pipe(fds);
    pid = fork();

    if(pid == 0){
        close(fds[0]);          // child closes read end
        write(fds[1],"hello",5);
        close(fds[1]);          // child closes write end
        exit(0);                // child exits
    }
    else{
        close(fds[1]);          // parent closes write end
        n = read(fds[0],buf,sizeof(buf));
        write(1,buf,n);
        close(fds[0]);          // parent closes read end
        wait(0);                // parent waits for child
        exit(0);                // parent exits
    }
}
