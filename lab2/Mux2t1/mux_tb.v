module mux_tb;
  reg s, D0, D1;
  wire y;
  mux2t1 mux_dut(s,D0,D1,y);
initial 
begin
    s= 0; D0 = 0; D1 =0; 
    #10 s=0; D0=0; D1=1; // select d0=0
    #10 s=0; D0=1; D1=0; // select d0=1
    #10 s=1; D0=0; D1=1; // select d1=1
    #10 s=1; D0=1; D1=0; // select d1=0 
  end
endmodule
