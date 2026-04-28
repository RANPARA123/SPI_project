module baud_rate_generator(pclk,preset,spi_mode,spiswai,sppr,spr,cpol,cpha,ss,sclk,miso_receive_sclk,miso_receive_sclk0,mosi_send_sclk,mosi_send_sclk0,baud_rate_division);
input pclk,preset,spiswai,cpol,cpha,ss;
input [1:0]spi_mode;
input [2:0]spr,sppr;
output reg sclk,miso_receive_sclk,miso_receive_sclk0,mosi_send_sclk,mosi_send_sclk0;
output [11:0]baud_rate_division;
reg[11:0]count;
wire pre_sclk;
assign pre_sclk=(cpol==1'b1) ? 1'b1:1'b0;
assign baud_rate_division=(sppr+1'b1)*(2'd2**(spr+1'b1));
//generate spi clock sclk
always@(posedge pclk,negedge preset)
begin
        if(!preset)
        begin
                count<=12'd0;
                sclk<=pre_sclk;
        end
        else if(!ss && !spiswai &&(spi_mode==2'b00 || spi_mode==2'b01))
        begin
                if(count==(baud_rate_division/2'b10)-1'b1)
                begin
                        count<=12'd0;
                        sclk<=~sclk;
                end
                else
                        count<=count+1'b1;
        end
        else
        begin
                sclk<=sclk;
                count<=12'd0;
        end
end
//generate miso flag
always@(posedge pclk,negedge preset)
begin
        if(!preset)
        begin
                miso_receive_sclk<=1'b0;
                miso_receive_sclk0<=1'b0;
        end
        else
        begin
                miso_receive_sclk<=1'b0;
                miso_receive_sclk0<=1'b0;
                if((!cpol && cpha) || (cpol && !cpha))
                begin
                        if(sclk)
                        begin
                                if(count==(baud_rate_division/2'd2)-1'd1)
                                        miso_receive_sclk0<=1'b1;
                        end
                end
                else if((!cpol && !cpha) || (cpol && cpha))
                begin
                        if(!sclk)
                        begin
                                if(count==(baud_rate_division/2'd2)-1'b1)
                                        miso_receive_sclk<=1'b1;
                        end
                end
        end
end
//generate mosi flag


always@(posedge pclk,negedge preset)
begin
        if(!preset)
        begin
                mosi_send_sclk<=1'b0;
                mosi_send_sclk0<=1'b0;
        end
        else
        begin
                mosi_send_sclk<=1'b0;
      mosi_send_sclk0<=1'b0;

                if ((!cpol && cpha) || (cpol && !cpha))
                begin
                        if(sclk)
                        begin
                                if(count==(baud_rate_division/2'd2)-2'd2)
                                        mosi_send_sclk<=1'b1;
                        end
                end
                else if((!cpol && !cpha) || (cpol && cpha))
                begin
                        if(!sclk)
                        begin
                                if(count==(baud_rate_division/2'd2)-2'd2)
                                        mosi_send_sclk0<=1'b1;
                        end
                end
        end
end
endmodule
