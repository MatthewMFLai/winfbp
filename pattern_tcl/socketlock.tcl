namespace eval SocketLock {

variable m_lock_socket
  
proc dummy_accept {newsock addr port} {
}

proc acquire_lock {lockid} {
    variable m_lock_socket
    set PORT [port_map "$lockid"]

    # 'socket already in use' error will be our lock detection mechanism
    if { [catch {socket -server dummy_accept $PORT} SOCKET] } {
        return "SOCKETLOCK_ERR: Could not acquire lock"
    }

    set m_lock_socket("$lockid") "$SOCKET"
    return "SOCKETLOCK_OK" 
}

proc release_lock {lockid} {

    variable m_lock_socket

    if { [catch {close $m_lock_socket("$lockid")} ERRORMSG] } {
        return "SOCKETLOCK_ERR: '$ERRORMSG' on closing socket for lock '$lockid'"
    }
    unset m_lock_socket("$lockid")
    return "SOCKETLOCK_OK" 
}

proc port_map {lockid} {

    # calculate our 'unique' port number using a hash function.
    # this mapping function comes from dr. KNUTH's art of programming volume 3.

    set LEN [string length $lockid]
    set HASH $LEN

    for {set IDX 0} {$IDX < $LEN} {incr IDX} {
        scan [string index "$lockid" $IDX] "%c" ASC
        set HASH [expr (($HASH<<5)^($HASH>>27))^$ASC];
    }

    # always use a prime for remainder
    # note that the prime number used here will basicly determine the maximum 
    # number of simultaneous locks

    return [expr (65535 - ($HASH % 101))]
}

}
