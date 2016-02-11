# --- Seyyed Mohammad Hosseini
# --- seyyedmohammad.ir
# --- 11-02-2016
# --- Implementation scenarios wireless connection, two nodes by other wireless node 

set val(chan)           Channel/WirelessChannel    ;
set val(prop)           Propagation/TwoRayGround   ;
set val(netif)          Phy/WirelessPhy            ;
set val(mac)            Mac/802_11                 ;
set val(ifq)            Queue/DropTail/PriQueue    ; 
set val(ll)             LL                         ;
set val(ant)            Antenna/OmniAntenna        ;
set val(ifqlen)         50                         ;
set val(nn)             3                          ;
set val(rp)             DSR                        ;
set val(x)              500                        ;
set val(y)              400                        ;
set val(stop)           150                        ;

set ns              [new Simulator]

set tracefd       [open first.tr w]
set windowVsTime2 [open win.tr w]
set namtrace      [open first.nam w]   

$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)


$ns node-config -adhocRouting $val(rp) \
           -llType $val(ll) \
           -macType $val(mac) \
           -ifqType $val(ifq) \
           -ifqLen $val(ifqlen) \
           -antType $val(ant) \
           -propType $val(prop) \
           -phyType $val(netif) \
           -channelType $val(chan) \
           -topoInstance $topo \
           -agentTrace ON \
           -routerTrace ON \
           -macTrace OFF \
           -movementTrace ON
           
for {set i 0} {$i < $val(nn) } { incr i } {
    set node_($i) [$ns node]     
}

$node_(0) set X_ 100.0
$node_(0) set Y_ 100.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 400.0
$node_(1) set Y_ 100.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 250.0
$node_(2) set Y_ 100.0
$node_(2) set Z_ 0.0

set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $node_(0) $tcp
$ns attach-agent $node_(1) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 0.0 "$ftp start"

proc plotWindow {tcpSource file} {
global ns
set time 0.01
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
puts $file "$now $cwnd"
$ns at [expr $now+$time] "plotWindow $tcpSource $file" }
$ns at 10.1 "plotWindow $tcp $windowVsTime2" 

for {set i 0} {$i < $val(nn)} { incr i } {
    $ns initial_node_pos $node_($i) 30
}

for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "$node_($i) reset";
}

$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at 150.01 "puts \"end simulation\" ; $ns halt"
proc stop {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
    exec nam first.nam &
    exit 0
}
$ns run
