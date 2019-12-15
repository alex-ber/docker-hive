bin=`cd "$(dirname $(which $0))" > /dev/null; pwd`

pdate () { echo $(date +%Y"-"%m"-"%d" "%H:%M:%S"."%N); }
echoerr() { cat <<< "$(pdate) ERROR $@" >&2; }
echowarn() { cat <<< "$(pdate) WARN $@" 1>&2; }
echoinfo() { cat <<< "$(pdate) INFO $@"; }


killit() {
 local PID=$@
 kill $PID
 sleep 2s
 # if process is still around, use kill -9
 if ps -p $PID > /dev/null ; then
     echoerr "Initial kill failed, getting serious now..."
     kill -9 $PID

 fi
 if ps -p $PID > /dev/null ; then
      echoerr "Wow, even kill -9 failed, giving up; sorry"
      exit 1
 fi
}

findpid(){
 local PID=$(ps aux | grep $@ | awk '{print $2}')
 echo $PID
}