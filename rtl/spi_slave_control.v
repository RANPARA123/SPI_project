module spi_slave_control_select(pclk,preset_n,mstr,spiswai,spi_mode,send_data,baud_rate_division,receive_data,ss,tip);
input pclk,preset_n,mstr,spiswai,send_data;
input [1:0]spi_mode;
input[11:0] baud_rate_division;
output reg receive_data,ss;
output tip;
reg rcv;
reg [15:0]count;
wire[15:0]target;


assign target=4'b1000*(baud_rate_division);
assign tip=~ss;
//generate counter
always@(posedge pclk,negedge preset_n)
begin
        if(!preset_n)
                count<=16'hFFFF;
        else
        begin
                count<=16'hFFFF;
                if(!spiswai && mstr && (spi_mode==2'b00||spi_mode==2'b01))
                begin
                        if(send_data )
                                count<=16'd0;
                        else
                        begin
                                if(count<target-1'b1)
                                        count<=count+1'b1;
                        end
                end
        end
end


//generate receiver_data
always@(posedge pclk, negedge preset_n)
begin
        if(!preset_n)
                receive_data<=1'b0;
        else
                receive_data<=rcv;
end

//generate rcv
always@(posedge pclk,negedge preset_n)
begin
        if(!preset_n)
                rcv<=1'b0;
        else
        begin
                rcv<=1'b0;
                if(!spiswai && mstr && (spi_mode==2'b00||spi_mode==2'b01))
                begin
                        if(send_data)
                                rcv<=1'b0;
                        else
                        begin
                                if(count<=target-1'b1)
                                begin
                                        if(count==target-1'b1)
                                                rcv<=1'b1;
                                end
                        end
                end
        end
end


//generate ss
always@(posedge pclk,negedge preset_n)
begin
        if(!preset_n)
                ss<=1'b1;
        else
        begin
                ss<=1'b1;
                if(!spiswai && mstr && (spi_mode==2'b00 || spi_mode==2'b01))
                begin
                        if(send_data)
                                ss<=1'b0;
                        else
                        begin
                                if(count<=target-1'b1)
                                        ss<=1'b0;
                        end
                end
        end
end

endmodule
