module floatingpoint32(en,A,B,C
    ); 
	input en;
   input[31:0] A,B;
   output[31:0] C;
   reg[31:0] C;
   reg[7:0] AE,BE,CE,DE;
   reg AS,BS,CS,DS;
   reg[24:0] AF,BF,CF;
   reg[7:0] index;
	integer in;
	integer tem;
   always @(A or B)//上升沿触发
   begin
      if(en==1)
         begin
	         AE=A[30:23];      //  阶码8位   用的是移码表示   +127 01111111
	         AF={2'b01,A[22:0]};//把缺省的1给补上    同时考虑做加法时  有可能产生进位  所以补齐23+1+1  共25位
	         AS=A[31];         //   最高位  即符号位
	         BE=B[30:23];
	         BF={2'b01,B[22:0]};
	         BS=B[31];
            //如果某一方阶码大，则符号位一定是在大的一方
	         if (A[30:0]==0)                 //如果A是0，则结果就是B了
	             begin
		               CS=BS;
		               CE=BE;
		               CF=BF;
	             end
	         else if(B[30:0]==0)             //如果B是0，则结果就是A了
                begin
	               	CS=AS;
	               	CE=AE;
	               	CF=AF;
	             end
            else                             //A、B都不为0的情况下
	             begin
	                if(AE>BE)                  //A的阶码大于B的阶码
	                 	 begin
		               	CE=AE;                //对阶
			               DE=AE-BE;             //阶码做差
			               BF=(BF>>DE);         //右移
			               if (AS==BS)        //如果A、B符号位相同，就做加法
			                   begin
			                          	CS=AS;
			                        	CF=AF+BF;
		                      end
		                  else if (AS!=BS)        //如果A、B的符号位不相同，就做减法
		                      begin
			                         	CS=AS;
			                        	CF=AF-BF;
		                      end
	               	 end
	            	 else if(AE<BE)              //A的阶码小于B的阶码
		                begin
			                CE=BE;               //对阶
			                DE=BE-AE;            //阶码做差
			                AF=(AF>>DE);         //右移
			                if (AS==BS)          //如果A、B符号位相同，就做加法
			                    begin
				                     CS=AS;
			                     	CF=AF+BF;
			                    end
			                else if (AS!=BS)          //如果A、B的符号位不相同，就做减法
			                    begin
			                       	CS=BS;
			                     	CF=BF-AF;
			                    end
		                end
		            else if(AE==BE)             //A的阶码等于B阶码
		                begin
			                CE=AE;               //首先确定结果的阶码
			                if (AS==BS)          // 如果A、B符号位相同，就做加法
		                  	  begin
				                    CS=AS;
			                  	  CF=AF+BF;
		                       end
		              	    else                 //如果A、B的符号位不相同，就做减法
			                    begin
			                  	  CS=BS;
			                       CF=BF-AF;
			                    end
		                end
		            //归一化，寻找CF第一个1，并将其前移
		           in=24;
		           tem=0;
		           while(tem==0&&in>=0)
		              begin
			              if(CF[in]!=0)//如果尾数最高位CF[24]即尾数第25位不为0，则可以进行尾数规一化。
			                 begin
				                  tem=1;
				                  index=in;     //index指示的就是尾数为1的那位 就是CF[index]=1
			                 end
			              in=in-1;         //这里要注意在找到index之后  in还会减一次
		              end                   //while循环这里结束了
		    if(in<0)//相加得0或者相减的结果就是0  也是指尾数运算结果为25位的0
		        begin
			        CS=0;        //运算结果就是0了
			        CE=0;
			        CF=0;
		        end
		    else if(index==24)//如果在24位，则尾码右移，阶码加一
		        begin
			        CE=CE+8'b1;   //结果C的阶码要加1
			        CF=(CF>>1);   //尾数要向右移一位    1.xxxxxxxxxx
		        end
          else		       
			     begin             
		       	  index=8'd23-index;    //index指示的是需要移位数
			        CE=CE-index;          //阶码减去左移的尾数
			        CF=(CF<<index);        //结果C的尾数要向左移index位
		        end
	                    end//
	          C={CS,CE,CF[22:0]};// 最终结果为32位  cs符号位  ce阶码   cf位尾数   忽略尾数最高的1  
         end//   if（en==1）
   end   //always@（A or B）
	 
	 
	 

endmodule
