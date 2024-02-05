mykey = 80000000000000000000000000000000
myin = 50a5ffe6ada8470916bfb9512e95c6ff
myout = 8997889b513ff24958e2bd3964984a3a

clean: 
	rm -r csrc
	rm -r simv.daidir
	rm simv
comp:
	#vcs -debug_all -f flist +define+MYKEY="128'h$(mykey)" +define+MYIN="128'h$(myin)" +define+MYOUT="128'h$(myout)" 
	# vcs -full64 -debug_all -f flist +v2k
	vcs -full64 -debug_acc+all+dmptf -debug_region+cell+encrypt -f flist +v2k
run:
#	./simv -gui
	./simv +vpdnocompress+loopreport
wf:
	dve -vpd AES_Comp_ENC.vcd &
#	dve -vpd example1_scan_ctrlogic.vpd &
	#dve -vpd netlist.vpd &
all:
	make comp
	make run
	make wf
