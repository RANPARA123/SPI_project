module top_module(pclk,preset_n,paddr,pwrite,psel,penable,pwdata,miso,ss,sclk,spi_interrupt_request,mosi,prdata,pready,pslverr);
input pclk,preset_n,pwrite,psel,penable,miso;
input [7:0]pwdata;
input[2:0]paddr;
output  ss,sclk,spi_interrupt_request,mosi,pready,pslverr;
output [7:0]prdata;



wire receive_w,tip,mstr,cpol,cpha,lsb,send_w,wait_w;
wire miso_receive_sclk0,miso_receive_sclk,mosi_send_sclk0,mosi_send_sclk;
wire [7:0]miso_w,mosi_w;
wire [1:0]mode;
wire [2:0]spr,sppr;
wire[11:0]baud_rate_division;

baud_rate_generator dut1 (.pclk(pclk),.preset(preset_n),.spi_mode(mode),.spiswai(wait_w),.sppr(sppr),.spr(spr),.cpol(cpol),.cpha(cpha),.ss(ss),.sclk(sclk),.miso_receive_sclk(miso_receive_sclk),.miso_receive_sclk0(miso_receive_sclk0),.mosi_send_sclk(mosi_send_sclk),.mosi_send_sclk0(mosi_send_sclk0),.baud_rate_division(baud_rate_division));


spi_slave_control_select dut2 (.pclk(pclk),.preset_n(preset_n),.mstr(mstr),.spiswai(wait_w),.spi_mode(mode),.send_data(send_w),.baud_rate_division(baud_rate_division),.receive_data(receive_w),.ss(ss),.tip(tip));


shift_register dut3 (.pclk(pclk),.preset_n(preset_n),.send_data(send_w),.ss(ss),.lsbfe(lsb),.cpol(cpol),.cpha(cpha),.miso_receive_sclk(miso_receive_sclk),.miso_receive_sclk0(miso_receive_sclk0),.mosi_send_sclk(mosi_send_sclk),.mosi_send_sclk0(mosi_send_sclk0),.data_mosi(mosi_w),.miso(miso),.receive_data(receive_w),.mosi(mosi),.data_miso(miso_w));


slave_interface dut4 (.pclk(pclk),.preset(preset_n),.pwrite(pwrite),.psel(psel),.penable(penable),.pwdata(pwdata),.ss(ss),.tip(tip),.receive_data(receive_w),.paddr(paddr),.miso_data(miso_w),.mstr(mstr),.cpol(cpol),.cpha(cpha),.lsbfe(lsb),.spiswai(wait_w),.sppr(sppr),.spr(spr),.spi_interrupt_request(spi_interrupt_request),.pready(pready),.pslverr(pslverr),.send_data(send_w),.spi_mode(mode),.prdata(prdata),.mosi_data(mosi_w));

endmodule
