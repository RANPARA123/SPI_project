module shift_register(pclk,preset_n,send_data,ss,lsbfe,cpol,cpha,miso_receive_sclk,miso_receive_sclk0,mosi_send_sclk,mosi_send_sclk0,data_mosi,miso,receive_data,mosi,data_miso);
input pclk,preset_n,send_data,ss,lsbfe,cpol,cpha,miso_receive_sclk,miso_receive_sclk0,mosi_send_sclk,mosi_send_sclk0,miso,receive_data;
input [7:0]data_mosi;
output reg mosi;
output  [7:0]data_miso;
reg [7:0]temp_reg;
reg[7:0]shift_reg;
reg [2:0]count0,count1,count2,count3;
assign data_miso=receive_data?temp_reg:8'b00000000;
//transmit data register logic (shift register load)
always@(posedge pclk or negedge preset_n)
begin
        if(!preset_n)
                shift_reg<=8'd0;
        else if(send_data)
                shift_reg<=data_mosi;
      // else
        //        shift_reg<=shift_reg;
end
//received data bit-by-bit (MISO)
always@(posedge pclk or negedge preset_n)
begin
        if(!preset_n)
        begin
                temp_reg<=8'd00;
                count2<=3'd0;
                count3<=3'd7;
        end
        else
        begin
                //temp_reg<=temp_reg;
                //
		//count2<=count2;
                //count3<=count3;
                if(!ss)
                begin
                        if((!cpha&&cpol)||(cpha&&!cpol))
                        begin
                                if(lsbfe)
                                begin
                                        if(count2<=3'd7)
                                        begin
                                                if(miso_receive_sclk0)
                                                begin
                                                        temp_reg[count2]<=miso;
                                                        count2<=count2+1'b1;
                                                end
                                        end
                                        else
                                                count2<=3'd0;
                                end
                                else
                                begin
                                        if(count3>=3'd0)
                                        begin
                                                if(miso_receive_sclk0)
                                                begin
                                                        temp_reg[count3]<=miso;
                                                        count3<=count3-1'd1;
                                                end
                                        end
                                        else
                                                count3<=3'd7;
                                end
                        end
                        else
                        begin
                                if(lsbfe)
                                begin
                                        if(count2<=3'd7)
                                        begin
                                                if(miso_receive_sclk)
                                                begin
                                                        temp_reg[count2]<=miso;
                                                        count2<=count2+1'b1;
                                                end
                                        end
                                        else
                                                count2<=3'd0;
                                end
                                else
                                begin
                                        if(count3>=3'd0)
                                        begin
                                                if(miso_receive_sclk)
                                                begin
                                                        temp_reg[count3]<=miso;
                                                        count3<=count3-1'd1;
                                                end
                                        end
                                        else
                                                count3<=3'd7;
                                end
                        end
                end
                else
                begin
                        temp_reg<=temp_reg;
                        count2<=count2;
                        count3<=count3;
                end
        end
end

//transmit data bit-by-bit (MOSI)
always@(posedge pclk or negedge preset_n)
begin
        if(!preset_n)
        begin
               // mosi<=1'b0;
                count0<=3'b000;
                count1<=3'b111;
        end
        else
        begin
               // mosi<=mosi;
               // count0<=count0;
                //count1<=count1;
                if(!ss)
                begin
                        if((!cpha&&cpol)||(cpha&&!cpol))
                        begin
                                if(lsbfe)
                                begin
                                        if(count0<=3'd7)
                                        begin
                                                if(mosi_send_sclk)
                                                begin
                                                        mosi<=shift_reg[count0];
                                                        count0<=count0+1'b1;
                                                end
                                        end
                                        else
                                                count0<=3'd0;
                                end
                                else//MSB transmission
                                begin
                                        if(count1>=3'd0)
                                        begin
                                                if(mosi_send_sclk)
                                                begin
                                                        mosi<=shift_reg[count1];
                                                        count1<=count1-1'd1;
                                                end
                                        end
                                        else
                                                count1<=3'd7;
                                end
                        end
                        else
                        begin
                                if(lsbfe)
                                begin
                                        if(count0<=3'd7)
                                        begin
                                                if(mosi_send_sclk0)
                                                begin
                                                        mosi<=shift_reg[count0];
                                                        count0<=count0+1'b1;
                                                end
                                        end
                                        else
                                                count0<=3'd0;
                                end
                                else
                                begin
                                        if(count1>=3'd0)
                                        begin
                                                if(mosi_send_sclk0)
                                                begin
                                                        mosi<=shift_reg[count1];
                                                        count1<=count1-1'd1;
                                                end
                                        end
                                        else
                                                count1<=3'd7;
                                end
                        end
                end
               /* else
                begin
                      //  mosi<=mosi;
                        count0<=count0;
                        count1<=count1;
                end*/
        end
end
endmodule
