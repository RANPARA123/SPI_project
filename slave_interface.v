module slave_interface(pclk,preset,pwrite,psel,penable,pwdata,ss,tip,receive_data,paddr,miso_data,mstr,cpol,cpha,lsbfe,spiswai,sppr,spr,spi_interrupt_request,pready,pslverr,send_data,spi_mode,prdata,mosi_data);

input pclk,preset,pwrite,psel,penable,ss,tip,receive_data;
input [2:0]paddr;
input [7:0]miso_data,pwdata;
output mstr,cpol,cpha,lsbfe,spiswai,pready,pslverr;
output reg spi_interrupt_request,send_data;
output reg[1:0]spi_mode;
output [2:0]sppr,spr;
output reg[7:0]mosi_data;

output reg [7:0]prdata;
//declaring internal registers
reg [7:0] spi_cr_1;
reg [7:0] spi_cr_2;
reg [7:0] spi_br;
reg [7:0] spi_sr;
reg [7:0] spi_dr;
wire spie,spe,sptie,ssoe; //spi_cr_1
wire modfen; //spi_cr_2
wire modf; //spi_sr
wire spif,sptef; //spi_sr

parameter cr_2mask =8'b00011011;
parameter br_mask =8'b01110111;
wire wr_enb,rd_enb;

parameter idle=2'b00,
          setup=2'b01,
          enable=2'b10;
reg [1:0]state,next_state;
parameter spi_run=2'b00,
          spi_wait=2'b01,
          spi_stop=2'b10;
reg [1:0]next_mode;
//apb slave fsm
always@(posedge pclk,negedge preset)
begin
        if(!preset)
                state<=idle;
        else
                state<=next_state;
end
always@(*)
begin
        case(state)
                idle:
                begin
                        if((psel)&&(!penable))
                                next_state=setup;
                        else
                                next_state=idle;
                end
                setup:
                begin
                        if((psel)&&(penable))
                                next_state=enable;
                        else if((psel)&&(!penable))
                                next_state=idle;
                        else
                                next_state=setup;
                end
                enable:
                begin
                        if(psel)
                                next_state=setup;
                        else
                                next_state=idle;
                end
                default next_state=idle;
        endcase
end
//spi mode
always@(posedge pclk,negedge preset)
begin
        if(!preset)
                spi_mode<=spi_run;
        else
                spi_mode<=next_mode;
end
always@(*)
begin
        case(spi_mode)
                spi_run:
                begin
                        if(!spe)
                                next_mode=spi_wait;
                        else
                                next_mode=spi_run;
                end
                spi_wait:
                begin
                        if(spiswai)
                                next_mode=spi_stop;
                        else if (spe)
                                next_mode=spi_run;
                        else
                                next_mode=spi_wait;
                end
                spi_stop:
                begin
                        if(!spiswai)
                                next_mode=spi_wait;
                        else
                                next_mode=spi_run;
                end
                default next_mode=spi_run;
        endcase
end

//pready
assign pready=(state==enable)?1'b1:1'b0;

//wr_enb
assign wr_enb=((state==enable)&&(pwrite))? 1'b1:1'b0;
assign rd_enb=((state==enable)&&(!pwrite))? 1'b1:1'b0;
//pslverr
assign pslverr=(state==enable)?(~tip):1'b0;
//spi_sr
always@(posedge pclk,negedge preset)
begin
        if(!preset)
                spi_sr<=8'b0010_0000;
        else
                spi_sr<={spif,1'b0,sptef,modf,4'b0000};
end
//spi_cr_1
always@(posedge pclk,negedge preset)
begin
        if(!preset)
                spi_cr_1<=8'h04;
        else
        begin
                if(wr_enb)
                begin
                        if(paddr==3'b000)
                                spi_cr_1<=pwdata;
                        else
                                spi_cr_1<=spi_cr_1;
                end
                else
                        spi_cr_1<=spi_cr_1;
        end
end
//spi_cr_2

always@(posedge pclk,negedge preset)
begin
        if(!preset)
                spi_cr_2<=8'h00;
        else
        begin
                if(wr_enb)
                begin
                        if(paddr==3'b001)
                                spi_cr_2<=cr_2mask & pwdata;
                        else
                                spi_cr_2<=spi_cr_2;
                end
                else
                        spi_cr_2<=spi_cr_2;
        end
end
//spi_br

always@(posedge pclk,negedge preset)
begin
        if(!preset)
                spi_br<=8'h00;
        else
        begin
                if(wr_enb)
                begin
                        if(paddr==3'b010)
                                spi_br<=br_mask & pwdata;
                        else
                                spi_br<=spi_br;
                end
                else
                        spi_br<=spi_br;
        end
end
//spi_dr
always@(posedge pclk,negedge preset)
begin
        if(!preset)
                spi_dr<=8'd0;
        else
        begin
                if(wr_enb)
                begin
                        if(paddr==3'b101)
                                spi_dr<=pwdata;
                        else
                                spi_dr<=spi_dr;
                end
                else
                begin
                        if((spi_dr==pwdata)&&(spi_dr!=miso_data)&&((spi_mode==spi_run) ||(spi_mode==spi_wait)))
                                spi_dr<=spi_dr;
                        else
                        begin
                                if(((spi_mode==spi_run)||(spi_mode==spi_wait))&&receive_data)
                                        spi_dr<=miso_data;
                                else
                                        spi_dr<=spi_dr;
                        end
                end
        end
end
//send_data
always@(posedge pclk, negedge preset)
begin
        if(!preset)
                send_data<=1'b0;
        else
        begin
                if(wr_enb)
                        send_data<=1'b0;
                else
                begin
                        if((spi_dr==pwdata)&&(spi_dr!=miso_data)&&((spi_mode==spi_run)||(spi_mode==spi_wait)))
                                send_data<=1'b1;
                        else
                                send_data<=1'b0;
                end
        end
end
//mosi_data
always@(posedge pclk,negedge preset)
begin
        if(!preset)
                mosi_data<=8'd0;
        else
        begin
                if((spi_dr==pwdata)&&(spi_dr!=miso_data)&&((spi_mode==spi_run)||(spi_mode==spi_wait)))
                        mosi_data<=spi_dr;
                else
                        mosi_data<=mosi_data;
        end
end

assign mstr=spi_cr_1[4];
assign cpol=spi_cr_1[3];
assign cpha=spi_cr_1[2];
assign ssoe=spi_cr_1[1];
assign lsbfe=spi_cr_1[0];
assign spie=spi_cr_1[7];
assign spe=spi_cr_1[6];
assign sptie=spi_cr_1[5];
assign modfen=spi_cr_2[4];
assign spiswai=spi_cr_2[1];
assign sppr=spi_br[6:4];
assign spr=spi_br[2:0];
assign modf=(!ss)&&(!ssoe)&&(mstr)&&(modfen);

//sptef
assign sptef=(spi_dr==8'd0)?1'b1:1'b0;
//spif
assign spif=(spi_dr!=8'd0)?1'b1:1'b0;
// spi_interrupt_request
always@(*)
begin
        if((!spie)&&(!sptie))
                spi_interrupt_request<=1'b0;
        else
        begin
                if((!sptie)&&(spie))
                        spi_interrupt_request<=spif | modf;
                else
                begin
                        if((!spie)&&(sptie))
                                spi_interrupt_request<=sptef;
                        else
                                spi_interrupt_request<=spif | modf | sptef;
                end
        end
end
//prdata
always@(*)
begin
	if(rd_enb)
	begin
		if(paddr==3'b000)
			prdata=spi_cr_1;
		else if(paddr==3'b001)
			prdata=spi_cr_2;
		else if (paddr==3'b010)
			prdata=spi_br;
		else if (paddr==3'b011)
			prdata=spi_sr;
		else if (paddr==3'b100)
			prdata=spi_dr;
		else
			prdata=8'b00000000;
	end
	else
		prdata=8'b00000000;
end
endmodule
