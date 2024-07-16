/* This module represents register file. It can be accessed by three addresses Addr1, AddR2, AddRd 
	and input data Rd, to output two wanted data Rs1 and Rs2 */
module Reg_file(clk , AddRd , AddR1 ,regfile, AddR2 , Rd , RegWrite , Rs1 , Rs2 );
	
	input wire clk ;
	input wire [2:0] AddRd,AddR1 ,AddR2; 
	input wire signed [15:0]	Rd ;  
	input wire RegWrite;
	output reg signed [15:0] Rs1,Rs2;  
	
	
	ref reg signed [15:0] regfile [7:0];	
	initial
		begin 
		 regfile[0] <=16'd0;
		end
	
	
	always @(posedge clk or Rd ) begin
        if (RegWrite == 1'b1) begin	
			if (AddRd != 3'b000) begin// If write address == R0, don't write because R0 is read only
            	regfile[AddRd] <= Rd; 
			end 	
        end
    end

    always @(posedge clk or AddR1 or AddR2 ) begin
        Rs1 <= regfile[AddR1];
        Rs2 <= regfile[AddR2];
    end
						
		
endmodule			
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/* This module represents PC Control unit, It chooses the value of PCsrc signal based on opcode */
module PC_control (clk , opcode , PCsrc );	
	
	
	input clk;
	input wire [3:0] opcode ; 
	output reg [1:0] PCsrc;
	
	
	always@(posedge clk or opcode)
		begin 
		
		if (opcode <4'b0000 & opcode > 4'b1111)// Handle unexpected opcode
			begin
			PCsrc <=2'b00;
			end 
		else if (opcode >= 4'b0000 & opcode <= 4'b0111)// normally
			begin 
			PCsrc <=2'b00;
			end 	
		else if (opcode > 4'b0111 & opcode <= 4'b1011) // Branch 
			begin 
			PCsrc <=2'b10;
			end 
		 else if (opcode > 4'b1011 & opcode <= 4'b1101)// jump 
			begin 
			PCsrc <=2'b01;
			end
		else 
			begin
			 PCsrc <=2'b11;	// R7 when Return from function 
			end
		
		end 
endmodule
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/* This module represents Instruction memory block. It contains the instructions to excute. The wanted instruction is fetched by the address (PC) */
module Instruction_Memory(clk,PC, instruction_memory, current_instruction);		  
	
	input clk; 
	input reg [15:0] PC;	 
	input reg [15:0] instruction_memory [31:0];
	output reg 	[15:0] current_instruction ;	
	
	always@(PC  or posedge clk  )
	begin
	current_instruction <= instruction_memory [PC];
	end 		
		 
	
endmodule
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/* This module represents Data memory block. It contains the data we may need to store on registers, also we can update data in it */
module Data_Memory(clk ,address, In_data ,MemWrite,data_mem , MemRead ,Out_data );
	
	input wire [15:0] address         ;	
	
	input clk ;
	
	input wire MemWrite , MemRead     ;
	
	input wire signed [15:0] In_data  ;
	 
	output reg signed [15:0] Out_data ;	
	
	ref reg signed  [15:0] data_mem [15:0];
					  
	always @(posedge clk  or address ) begin
        if ( MemRead == 1'b1 && MemWrite == 1'b0 ) begin	
				Out_data <= data_mem[address]; 	  		
        end	
    end

    always @(posedge clk or In_data or address ) begin
         if ( MemRead == 1'b0  && MemWrite == 1'b1 ) begin	
				data_mem[address] <= In_data; 	  		
        end
    end
	
	
endmodule
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/* This module represent Main conrol unit. It is responsable of generating the majority of signals needed in data path.
	The signals generated based on opcode and mode bit. More details are discussed in report (theory) */
module Control_Unit(clk , opcode , mode,DataStrd ,RBDST ,BRSgn, RegWr , ExtOp , ALUsrc , MemWr , MemRd , WBdata , ByteExt ,CallSgn ,Retsgn ,Svsgn);
	input clk ;
	input wire [3:0] opcode ;
	input wire mode  ;
	output reg DataStrd ,RBDST ,BRSgn, RegWr , ExtOp , ALUsrc , MemWr , MemRd , WBdata , ByteExt ,CallSgn ,Retsgn ,Svsgn; 
	
	always@(posedge clk or opcode or mode )
		case(opcode)
		
		4'b0000:// AND 
		begin 
		BRSgn   <= 1'b0 ;
		RegWr   <= 1'b1 ; 
		RBDST   <= 1'b0	;
		ExtOp   <= 1'bx ; 
		ALUsrc  <= 1'b0 ; 
		MemWr   <= 1'b0 ;	  
		MemRd   <= 1'b0 ;	  
		WBdata  <= 1'b0 ;	  
		CallSgn <= 1'b0 ;  
		Retsgn  <= 1'b0 ;	  
		Svsgn   <= 1'b0 ;	  
		ByteExt	<= 1'b0 ;	 
		DataStrd<= 1'b0 ;
		end	  
		
		4'b0001 :// ADD
		begin 	
		BRSgn   <= 1'b0 ;
		RegWr   <= 1'b1 ;  
		RBDST   <= 1'b0	;
		ExtOp   <= 1'bx ; 
		ALUsrc  <= 1'b0 ;  
		MemWr   <= 1'b0 ;	
		MemRd   <= 1'b0 ;	  
		WBdata  <= 1'b0 ;	
		CallSgn <= 1'b0 ;   
		Retsgn  <= 1'b0 ;	  
		Svsgn   <= 1'b0 ;	  
		ByteExt	<= 1'b0 ;	  
		DataStrd<= 1'b0 ;
		end	  
		
		4'b0010 :// SUB
		begin 
		BRSgn   <= 1'b0 ;
		RegWr   <= 1'b1 ; 
		RBDST   <= 1'b0	;
		ExtOp   <= 1'bx ; 
		ALUsrc  <= 1'b0 ;  
		MemWr   <= 1'b0 ;	  
		MemRd   <= 1'b0 ;	 
		WBdata  <= 1'b0 ;	 
		CallSgn <= 1'b0 ;   
		Retsgn  <= 1'b0 ;	  
		Svsgn   <= 1'b0 ;	   
		ByteExt	<= 1'b0 ;	 
		DataStrd<= 1'b0 ;
		end
		
		4'b0011:// ADDI 
		begin
		BRSgn   <= 1'b0 ;
		RegWr   <= 1'b1 ;  
		RBDST   <= 1'bx	;
		ExtOp   <= 1'b1 ; 
		ALUsrc  <= 1'b1 ;  
		MemWr   <= 1'b0 ;	 
		MemRd   <= 1'b0 ;	  
		WBdata  <= 1'b0 ;	 
		CallSgn <= 1'b0 ;   
		Retsgn  <= 1'b0 ;	 
		Svsgn   <= 1'bx ;	 
		ByteExt	<= 1'b0 ;	 
		DataStrd<= 1'b0 ;
		end 
		
		4'b0100: // ANDI 
		begin
		BRSgn   <= 1'b0 ;
		RegWr   <= 1'b1 ;  
		RBDST   <= 1'bx	;
		ExtOp   <= 1'b0 ; 
		ALUsrc  <= 1'b1 ; 
		MemWr   <= 1'b0 ;	 
		MemRd   <= 1'b0 ;	
		WBdata  <= 1'b0 ;	  
		CallSgn <= 1'b0 ;  
		Retsgn  <= 1'b0 ;	 
		Svsgn   <= 1'bx ;	  
		ByteExt	<= 1'b0 ;	  
		DataStrd<= 1'b0 ;
		end   
		
		4'b0101: // LW  
		begin
		BRSgn   <= 1'b0 ;
		RegWr   <= 1'b1 ; 
		RBDST   <= 1'bx	;
		ExtOp   <= 1'b1 ; 
		ALUsrc  <= 1'b1 ; 
		MemWr   <= 1'b0 ;	  
		MemRd   <= 1'b1 ;	  
		WBdata  <= 1'b1 ;	  
		CallSgn <= 1'b0 ; 
		Retsgn  <= 1'b0 ;	 
		Svsgn   <= 1'bx ;	 
		ByteExt	<= 1'b0 ;	
		DataStrd<= 1'b0 ;
		end 
		
		4'b0110: 
		begin 
		if (mode ==1'b0 ) // LBu
		begin 	
		BRSgn   <= 1'b0 ;
		RegWr   <= 1'b1 ; 
		RBDST   <= 1'bx	;
		ExtOp   <= 1'b1 ; 
		ALUsrc  <= 1'b1 ; 
		MemWr   <= 1'b0 ;	
		MemRd   <= 1'b1 ;	  
		WBdata  <= 1'b1 ;	  
		CallSgn <= 1'b0 ;   
		Retsgn  <= 1'b0 ;	  
		Svsgn   <= 1'bx ;	  
		ByteExt	<= 1'b0 ;	  
		DataStrd<= 1'b0 ;	
		end					  
		else if (mode ==1'b1 ) // LBs			
		begin
		BRSgn   <= 1'b0 ;
		RegWr   <= 1'b1 ; 
		RBDST   <= 1'bx	;
		ExtOp   <= 1'b1 ; 
		ALUsrc  <= 1'b1 ;
		MemWr   <= 1'b0 ;	  
		MemRd   <= 1'b1 ;	 
		WBdata  <= 1'b1 ;	  
		CallSgn <= 1'b0 ;  
		Retsgn  <= 1'b0 ;	 
		Svsgn   <= 1'bx ;	 
		ByteExt	<= 1'b1 ;	  
		DataStrd<= 1'b0 ;			
		end	
		end 	
		
		4'b0111 : // SW 
		begin 
		BRSgn   <= 1'b0 ;
		RegWr   <= 1'b0 ; 
		RBDST   <= 1'b1	;
		ExtOp   <= 1'b1 ; 
		ALUsrc  <= 1'b1 ;  
		MemWr   <= 1'b1 ;	 
		MemRd   <= 1'b0 ;	  
		WBdata  <= 1'bx ;	
		CallSgn <= 1'bx ;   
		Retsgn  <= 1'b0 ;	  
		Svsgn   <= 1'b0 ;	
		ByteExt	<= 1'bx ;	
		DataStrd<= 1'bx ;
		end		
		
		4'b1000 : 
		begin 
			if (mode ==1'b0) // BGT
				begin	
					BRSgn   <= 1'b0 ;
					RegWr   <= 1'b0 ; 
					RBDST   <= 1'b1	;
					ExtOp   <= 1'b1 ; 
					ALUsrc  <= 1'b0 ;
					MemWr   <= 1'b0 ;	  
					MemRd   <= 1'b0 ;	  
					WBdata  <= 1'bx ;	  
					CallSgn <= 1'bx ;  
					Retsgn  <= 1'b0 ;	  
					Svsgn   <= 1'b0 ;	  
					ByteExt	<= 1'bx ;	  
					DataStrd<= 1'bx ;
				end
			else if (mode ==1'b1)// BGTZ
				begin	
					BRSgn   <= 1'b1 ;
					RegWr   <= 1'b0 ; 
					RBDST   <= 1'b1	;
					ExtOp   <= 1'b1 ; 
					ALUsrc  <= 1'b0 ;
					MemWr   <= 1'b0 ;	  
					MemRd   <= 1'b0 ;	  
					WBdata  <= 1'bx ;	  
					CallSgn <= 1'bx ;  
					Retsgn  <= 1'b0 ;	  
					Svsgn   <= 1'b0 ;	  
					ByteExt	<= 1'bx ;	  
					DataStrd<= 1'bx ;
				end
			
		end	
		
		4'b1001: 
		begin 
		if (mode ==1'b0)// BLT
				begin	
					BRSgn   <= 1'b0 ;
					RegWr   <= 1'b0 ; 
					RBDST   <= 1'b1	;
					ExtOp   <= 1'b1 ; 
					ALUsrc  <= 1'b0 ;
					MemWr   <= 1'b0 ;	  
					MemRd   <= 1'b0 ;	  
					WBdata  <= 1'bx ;	  
					CallSgn <= 1'bx ;  
					Retsgn  <= 1'b0 ;	  
					Svsgn   <= 1'b0 ;	  
					ByteExt	<= 1'bx ;	  
					DataStrd<= 1'bx ;
				end
			else if (mode ==1'b1)// BLTZ
				begin	
					BRSgn   <= 1'b1 ;
					RegWr   <= 1'b0 ; 
					RBDST   <= 1'b1	;
					ExtOp   <= 1'b1 ; 
					ALUsrc  <= 1'b0 ;
					MemWr   <= 1'b0 ;	  
					MemRd   <= 1'b0 ;	  
					WBdata  <= 1'bx ;	  
					CallSgn <= 1'bx ;  
					Retsgn  <= 1'b0 ;	  
					Svsgn   <= 1'b0 ;	  
					ByteExt	<= 1'bx ;	  
					DataStrd<= 1'bx ;
				end
		end	  
		
		4'b1010 : 
		begin 
		if (mode ==1'b0)// BEQ
				begin	
					BRSgn   <= 1'b0 ;
					RegWr   <= 1'b0 ; 
					RBDST   <= 1'b1	;
					ExtOp   <= 1'b1 ; 
					ALUsrc  <= 1'b0 ;
					MemWr   <= 1'b0 ;	  
					MemRd   <= 1'b0 ;	  
					WBdata  <= 1'bx ;	  
					CallSgn <= 1'bx ;  
					Retsgn  <= 1'b0 ;	  
					Svsgn   <= 1'b0 ;	  
					ByteExt	<= 1'bx ;	  
					DataStrd<= 1'bx ;
				end
			else if (mode ==1'b1)// BEQZ
				begin	
					BRSgn   <= 1'b1 ;
					RegWr   <= 1'b0 ; 
					RBDST   <= 1'b1	;
					ExtOp   <= 1'b1 ; 
					ALUsrc  <= 1'b0 ;
					MemWr   <= 1'b0 ;	  
					MemRd   <= 1'b0 ;	  
					WBdata  <= 1'bx ;	  
					CallSgn <= 1'bx ;  
					Retsgn  <= 1'b0 ;	  
					Svsgn   <= 1'b0 ;	  
					ByteExt	<= 1'bx ;	  
					DataStrd<= 1'bx ;
				end		
		end	
		
		4'b1011 :	
		begin 
		if (mode ==1'b0)// BNE
				begin	
					BRSgn   <= 1'b0 ;
					RegWr   <= 1'b0 ; 
					RBDST   <= 1'b1	;
					ExtOp   <= 1'b1 ; 
					ALUsrc  <= 1'b0 ;
					MemWr   <= 1'b0 ;	  
					MemRd   <= 1'b0 ;	  
					WBdata  <= 1'bx ;	  
					CallSgn <= 1'bx ;  
					Retsgn  <= 1'b0 ;	  
					Svsgn   <= 1'b0 ;	  
					ByteExt	<= 1'bx ;	  
					DataStrd<= 1'bx ;
				end
			else if (mode ==1'b1)// BNEZ
				begin	
					BRSgn   <= 1'b1 ;
					RegWr   <= 1'b0 ; 
					RBDST   <= 1'b1	;
					ExtOp   <= 1'b1 ; 
					ALUsrc  <= 1'b0 ;
					MemWr   <= 1'b0 ;	  
					MemRd   <= 1'b0 ;	  
					WBdata  <= 1'bx ;	  
					CallSgn <= 1'bx ;  
					Retsgn  <= 1'b0 ;	  
					Svsgn   <= 1'b0 ;	  
					ByteExt	<= 1'bx ;	  
					DataStrd<= 1'bx ;
				end		
		end	
		
		4'b1100:// JMP	
		begin	
					BRSgn   <= 1'b1 ;
					RegWr   <= 1'b0 ; 
					RBDST   <= 1'bx	;
					ExtOp   <= 1'b1 ; 
					ALUsrc  <= 1'bx ;
					MemWr   <= 1'b0 ;	  
					MemRd   <= 1'b0 ;	  
					WBdata  <= 1'bx ;	  
					CallSgn <= 1'bx ;  
					Retsgn  <= 1'b0 ;	  
					Svsgn   <= 1'b0 ;	  
					ByteExt	<= 1'bx ;	  
					DataStrd<= 1'bx ;
		end	
		
		4'b1101:// CALL			 
		begin	
					BRSgn   <= 1'b1 ;
					RegWr   <= 1'b1 ; 
					RBDST   <= 1'bx	;
					ExtOp   <= 1'b1 ; 
					ALUsrc  <= 1'bx ;
					MemWr   <= 1'b0 ;	  
					MemRd   <= 1'b0 ;	  
					WBdata  <= 1'bx ;	  
					CallSgn <= 1'b1 ;  
					Retsgn  <= 1'b0 ;	  
					Svsgn   <= 1'b0 ;	  
					ByteExt	<= 1'bx ;	  
					DataStrd<= 1'b1 ;
		end	
		4'b1110 :// RET	
		begin	
					BRSgn   <= 1'b0 ;
					RegWr   <= 1'b0 ; 
					RBDST   <= 1'bx	;
					ExtOp   <= 1'b1 ; 
					ALUsrc  <= 1'bx ;
					MemWr   <= 1'b0 ;	  
					MemRd   <= 1'b0 ;	  
					WBdata  <= 1'bx ;	  
					CallSgn <= 1'bx ;  
					Retsgn  <= 1'b1 ;	  
					Svsgn   <= 1'b0 ;	  
					ByteExt	<= 1'bx ;	  
					DataStrd<= 1'bx ;
		end	 
		
		4'b1111 :// Sv	
		begin	
					BRSgn   <= 1'b0 ;
					RegWr   <= 1'b0 ; 
					RBDST   <= 1'bx	;
					ExtOp   <= 1'b1 ; 
					ALUsrc  <= 1'bx ;
					MemWr   <= 1'b1 ;	  
					MemRd   <= 1'b0 ;	  
					WBdata  <= 1'bx ;	  
					CallSgn <= 1'bx ;  
					Retsgn  <= 1'b0 ;	  
					Svsgn   <= 1'b1 ;	  
					ByteExt	<= 1'bx ;	  
					DataStrd<= 1'bx ;
		end	
		default:	
		begin	
					BRSgn   <= 1'b0 ;
					RegWr   <= 1'b0 ; 
					RBDST   <= 1'bx	;
					ExtOp   <= 1'b1 ; 
					ALUsrc  <= 1'bx ;
					MemWr   <= 1'b1 ;	  
					MemRd   <= 1'b0 ;	  
					WBdata  <= 1'bx ;	  
					CallSgn <= 1'bx ;  
					Retsgn  <= 1'b0 ;	  
					Svsgn   <= 1'b1 ;	  
					ByteExt	<= 1'bx ;	  
					DataStrd<= 1'bx ;
		end	
		endcase	
			
		    	
endmodule 
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/* This module represents ALU block. It's responsable for excuting arithmetic and logic operation on operands.
	Also generating control signals like zero and sign */
module ALU (clk, ALUOP , Rs1 , Rs2 , AluOut , zero ,sign );
	
	input clk ;
	input [3:0] ALUOP ;
	input wire signed [15:0] Rs1, Rs2; 
	output reg signed [15:0] AluOut; 
	output reg zero,sign ; 
	initial
		begin
		zero =1'b0;
		sign =1'b0;
		end	
		
	always @(posedge clk or ALUOP or Rs1 or Rs2 or AluOut or zero or sign  )	
    case (ALUOP)
		//opcode		    
        4'b0000 : AluOut = Rs1 & Rs2 ; 
        4'b0001 : AluOut = Rs1 + Rs2 ; 
        4'b0010 : AluOut = Rs1 - Rs2 ;
		4'b0011 : AluOut = Rs1 + Rs2 ;
		4'b0100 : AluOut = Rs1 & Rs2 ;
		4'b0101 : AluOut = Rs1 + Rs2 ;
		4'b0110 : AluOut = Rs1 + Rs2 ;	
		4'b0111 : AluOut = Rs1 + Rs2 ;
		4'b1000 : begin 
		// Generation of zero and sign signals	
		if( Rs2 > Rs1 )begin
			 sign <= 1'b0;
			end 
				
		else begin	
			sign <= 1'b1 ;		 
		end 
		
		end	 
		////////////////////
		4'b1001 : begin 
			
		if( Rs2 < Rs1 )begin
			 sign <= 1'b1;
			end 
				
		else begin	
			sign <= 1'b0 ;		 
		end 
		
		end	 
		////////////////////
		4'b1010 : begin 
			
		if( Rs2 == Rs1 )begin
			 zero <= 1'b1;
			end 
				
		else begin	
			zero <= 1'b0 ;		 
		end   
		
		end	
		//////////////////// 
		4'b1011 : begin 
			
		if( Rs2 != Rs1 )begin
			 zero <= 1'b0;
			end 
				
		else begin	
			zero <= 1'b1 ;		 
		end   
		
		end	
		////////////////////
		
		
		default: AluOut = 16'd0; 
   endcase
endmodule
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  
/* This module represent the top module in our design. It's a multi-cylce processor. */
module Multi_Cycle_Proccesser(clk ,Instruction_memory , Data_memory , Reg_File , Reg_file_out , Data_Memory_out,Opcode ,PC,current_instruction,
	stage, Rd,Rs1,Rs2,RW,RB ,RA ,Rtemp,BUSA ,BUSB ,BUSW,DATA,Temp_BUS,DataStrd,Address_DM ,Data_in_DM, Data_Out_DM,Data_Out_DM_temp, ByteExt,PCsrc);  
	// Defining inputs and outputs 
	reg reset;
	input clk;
	ref    reg [15:0] Instruction_memory [31:0];	
	ref    reg signed  [15:0] Data_memory [15:0]; 			   
	ref    reg signed [15:0] Reg_File [7:0];
	output reg signed  [15:0] Data_Memory_out [15:0]; 			   
	output reg signed [15:0] Reg_file_out [7:0]; 
	output reg [15:0] PC;
	output reg [15:0] current_instruction;
	output reg [3:0 ]  Opcode;	
	output reg [2 : 0 ] stage;
	output reg [1 : 0 ] PCsrc; 							  
	reg [15: 0 ] extimmd_jump;  
	reg [11: 0 ] jump_immd;
	reg [4 : 0 ] Branch_immd;
	reg [4 : 0 ] immd_5b;
	reg [8 : 0 ] Simmd;	
	reg [15: 0 ] immd;
	output reg signed  [15: 0 ] BUSA ,BUSB ,BUSW,DATA;// DATA from write Back 
	output reg signed[15: 0 ] Temp_BUS; 
	reg [15: 0 ] Result; 
	output reg [15: 0 ] Address_DM ,Data_in_DM, Data_Out_DM;
	output reg [15: 0 ] Data_Out_DM_temp;	
	reg mode ;
	reg sign ;
	reg zero ;
	output reg  [2:0] Rd,Rs1,Rs2;
	output reg [2:0] RW,RB ,RA ,Rtemp;// input of register file 
	reg  RBDST ,BRSgn, RegWr , ExtOp , ALUsrc , MemWr , MemRd , WBdata  ,CallSgn ,Retsgn ,Svsgn;
	output reg DataStrd , ByteExt;
	
	initial
		begin
		PC=16'd0; // Initializing 
		stage<=3'b000;
		end 	
	
	 // fetch stage   
	
	 Instruction_Memory Inst (clk ,PC,Instruction_memory, current_instruction );// Fetch instruction from instruction memory using PC as address  
   	 assign Opcode=	current_instruction[3:0];// Extracting opcode	
	 assign mode=	current_instruction[4];// Extracting mode	
	
	  PC_control PCsrrc (clk ,Opcode,PCsrc);// Generating PCsrc 
	  
	  
	  Control_Unit signals (clk ,Opcode,mode ,DataStrd ,RBDST ,BRSgn, RegWr , ExtOp , ALUsrc , MemWr , MemRd , WBdata , ByteExt ,CallSgn ,Retsgn ,Svsgn );// Generating main control signals
	  ALU alu (clk, Opcode , BUSA , Temp_BUS , Result , zero ,sign );// Calling ALU to excute operation based on opcode 
	  Data_Memory data_mem (clk ,Address_DM, Data_in_DM ,MemWr,Data_memory , MemRd ,Data_Out_DM );// Get data from data memory using address	
	  Reg_file registers (clk , RW , RA ,Reg_File, RB , BUSW , RegWr , BUSA , BUSB );// Get data from registers	 
	
	
	  // fetch stage 
	always @(posedge clk or PC )
		begin
			if (stage ==3'b000)
				begin 
				 	  if (PCsrc==0)
							begin 
								PC=PC+1;
							end	 
					stage =3'b001;			
				end 			
		end	   
		
		 always @(posedge clk or current_instruction or PC or jump_immd or extimmd_jump)
			 begin
				 if (stage ==3'b000) 
					 begin
				 	if(PCsrc==1) 
						begin  	
							jump_immd=current_instruction[13:4];	
							extimmd_jump = {PC[15:10], jump_immd}; 	 
							PC=PC+extimmd_jump; 
						end
					stage =3'b001;	
					end 	
			 end  
			 
		 always @(posedge clk  or current_instruction or PC or Branch_immd )
			 begin	
			 if (stage ==3'b000)
				 begin 
				 if(PCsrc==2)
					begin
					if (Opcode==4'b1000) //BGT &BGTZ
						begin
						if(sign==1'b0)
							begin
							Branch_immd= {current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15:11]};
							PC=PC+Branch_immd;
						    end
						else 
							begin
							PC=PC+1;	
							end 	
							
						end	
					else if (Opcode==4'b1001 )//BLT & BLTZ
						begin
						if(sign==1'b1)
							begin
							Branch_immd= {current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15:11]};
							PC=PC+Branch_immd;
						    end
						else 
							begin
							PC=PC+1;	
							end 	
						end
	
					else if (Opcode==4'b1010)//BEQ 
						begin
						if(zero==1'b1)
							begin
							Branch_immd= {current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15:11]};
							PC=PC+Branch_immd;
						    end
						else 
							begin
							PC=PC+1;	
							end 	
						end	
						
					
					else if (Opcode==4'b1011)//BNE 
						begin
						if(zero==1'b0)
							begin
							Branch_immd= {current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15],current_instruction[15:11]};
							PC=PC+Branch_immd;
						    end
						else 
							begin
							PC=PC+1;	
							end 	
							end	
						
						end 
					stage =3'b001;		
					end	  
				 end  
				 
				 
				 
				 
				 
		 always @(posedge clk or BUSA )
			 begin
				 if (stage ==3'b000)
					begin 
					 if (PCsrc==3)
						begin
						PC=BUSA;	
						end
						stage =3'b001;
					end 	
			 end 
				
	
				// fetch stage end 
				
			
				
			//decode 	
			always @(posedge clk or current_instruction or PC )
		begin	 
			if (stage == 3'b001)
				begin 
				if (Opcode >= 4'b0000 & Opcode <= 4'b0010)// R-Type
					begin 
					   Rd  <=current_instruction[6:4];
					   Rs1 <=current_instruction[9:7];
					   Rs2 <=current_instruction[12:10];
					end
				else if (Opcode >= 4'b0011 & Opcode <= 4'b1011)// I-Type 
 					begin
					   // we declare mode in assign where is work (if opcode Itype then correct mode )
					   Rd	<=current_instruction[7:5];
					   Rs1	<=current_instruction[10:8 ];
					   immd_5b <=current_instruction[15:11 ];
					   
					end
				else if (Opcode == 4'b1111 )// S-Type 	
					begin
						Rs1   <=current_instruction[6:4];
						Simmd <=current_instruction[15:7];
					end	
			end 
			
			end 
			
			
			always @(posedge clk or Rs1 or current_instruction or PC )
				begin		   
				if (stage == 3'b001)
				begin 
				//////////RA (RS1)
				if (Retsgn == 1'b0)
					begin
					Rtemp <=Rs1;
					end
				else 
					begin
					Rtemp <=3'b111;
					end	
				end 	
			end	 
			
		always @(posedge clk  or Rtemp or current_instruction or PC  )
			begin	 
			  if (stage == 3'b001)
				begin 
				if (BRSgn == 1'b0)
					begin
					RA <=Rtemp;
					end
				else 
					begin
					RA <=3'b000;
					end	 
				end 
				
		end
				  ////////////RA (RS1)  
		always @(posedge clk or Rs2 or current_instruction or PC)
		begin
				if (stage == 3'b001)
				begin 
				
				
				////////////RB (RS2) 
				if (RBDST == 1'b0)
					begin
					RB <= Rs2;
					end
				else 
					begin
					RB <= Rd;
					end	 
				
				end 
				end 
		 	   ////////////RB (RS2) 
		 
					
				always @(posedge clk or Rd  )
		begin
				if (stage == 3'b001)
				begin 
				
				////////////RW (Rd) 
				if (CallSgn == 1'b0)
					begin
					RW <= Rd;
					end
				else 
					begin
					RW <= 3'b111;
					end
					
				////////////RW (Rd)	
				end
			end
				
		 always @(posedge clk or immd_5b )
		begin		
			if (stage == 3'b001)
				begin 
			
				/////////// Extinder
				if (ExtOp == 1'b0)
					begin// zero extinsion
					immd <= {11'b00000000000 , immd_5b } ;
					end
				else 
					begin//sign extinsion
					immd <= {immd_5b[4],immd_5b[4],immd_5b[4],immd_5b[4],immd_5b[4],immd_5b[4],immd_5b[4],immd_5b[4],immd_5b[4],immd_5b[4],immd_5b[4] , immd_5b } ;
					end
				/////////// Extinder
		
				end
			end 
		
				
			 always @(posedge clk  or immd or BUSB)
					begin	
				  if (stage == 3'b001)
				begin 
					if (ALUsrc == 1'b1)
						begin
							Temp_BUS <= immd ;	
						end	
					else 
						begin
							Temp_BUS <= BUSB;
						end	
						stage <= 3'b010;
				 end 
				 
				  //if (Opcode == 4'b1100 || Opcode == 4'b1101 ||Opcode == 4'b1110  )
				//begin
				//	stage <= 3'b000 ;		
				//end 
				  end 
				  	  
				
		//ALU		
		 always @(posedge clk  or  BUSA or Result )
		begin	
			if (stage == 3'b010)
				begin	
					if (Svsgn == 1'b1)
						begin
						
						Address_DM <=BUSA;
						end
					else
						begin
						
						Address_DM <= Result;
						end	 
						
					
					//if (Opcode >= 4'b1000 && Opcode <= 4'b1011 )
				//begin
				//	stage = 3'b000 ;		
				//end

					
					end 
				
				
						
			  end 
			   always @(posedge clk  or Simmd  or BUSB  )
		begin	
			if (stage == 3'b010)
				begin	
					if (Svsgn == 1'b1)
						begin
						Data_in_DM <={Simmd[8],Simmd[8],Simmd[8],Simmd[8],Simmd[8],Simmd[8],Simmd[8],Simmd};
						
						end
					else
						begin
						Data_in_DM <= BUSB;
						end	 
						
					stage <= 3'b011;
					//if (Opcode >= 4'b1000 && Opcode <= 4'b1011 )
				//begin
				//	stage = 3'b000 ;		
				//end

					
					end 
				
				
						
			  end 
			  
			  
	/////////////////////////////////		  
			  
			  
			  
			  //end of ALU
		 always @(posedge clk or Data_Out_DM)
		begin	
			if (stage == 3'b011)
				begin		
					if (ByteExt == 1'b0)
						begin
							Data_Out_DM_temp <= {12'b000000000000 ,Data_Out_DM[3:0] }  ;
						end
					else if (ByteExt == 1'b1)																																													
						begin
							Data_Out_DM_temp <= {Data_Out_DM[3],Data_Out_DM[3],Data_Out_DM[3],Data_Out_DM[3],Data_Out_DM[3],Data_Out_DM[3],Data_Out_DM[3],Data_Out_DM[3],Data_Out_DM[3],Data_Out_DM[3],Data_Out_DM[3],Data_Out_DM[3],Data_Out_DM[3:0] }  ;
						end	
				stage <= 3'b100;		
				end 						
			  end 	   
			 
			  
		 always @(posedge clk or Data_Out_DM_temp or Result)
		begin		
		if (stage == 3'b100)
			begin		
					if (WBdata  == 1'b1)
						begin
							DATA <= Data_Out_DM_temp	;
						end
					else
						begin
							DATA <= Result;
						end
									
				end 	
		end			  
			  
		always @(posedge clk or DATA or PC )
		begin	
			if (stage == 3'b100)
			begin
			  
				if (DataStrd == 1'b0)
					begin
					BUSW <= DATA;
					end
				else 
					begin
					BUSW <= PC+1;
					end
					stage <= 3'b000;
			  	 end
			  end 	  		
		
		assign Reg_file_out = Reg_File ;
		assign Data_Memory_out = Data_memory ;
		
endmodule 
// This module represents testbench
module TB_Multi_Cycle_Proccesser;
	reg clk ; 
	reg [15:0] Instruction_memory [31:0]         ;
	reg signed  [15:0] Data_memory [15:0]     ;
	reg signed [15:0] Reg_File [7:0] 	         ;
	wire signed  [15:0] Data_Memory_out [15:0];
	wire signed [15:0] Reg_file_out [7:0]        ;	
	wire [3:0]Opcode; 
	wire  [15:0] PC,current_instruction ;
	wire [2:0] Stage ;
	wire  [2:0] Rd,Rs1,Rs2,RW,RB ,RA ,Rtemp; 
	wire signed [15: 0 ] BUSA ,BUSB ,BUSW,DATA,Temp_BUS ;
	wire DataStrd, ByteExt;
	wire signed [15:0] Data_in_DM, Data_Out_DM ,Data_Out_DM_temp;
	wire  [15:0]  Address_DM ; 
	wire   [1:0] PCsrc;
	
	integer i,j;
	integer print_counter = 0;
	Multi_Cycle_Proccesser MCP (clk ,Instruction_memory , Data_memory , Reg_File 
	, Reg_file_out , Data_Memory_out,Opcode ,PC,current_instruction,Stage,Rd,Rs1,Rs2,RW,RB ,RA 
	,Rtemp, BUSA ,BUSB ,BUSW,DATA,Temp_BUS,DataStrd,Address_DM ,Data_in_DM, Data_Out_DM,Data_Out_DM_temp, ByteExt,PCsrc);  

	initial
		begin
		for (i = 0; i < 8; i = i + 1) begin
                Reg_File[i] = i;
		end
		for (i = 0; i < 8; i = i + 1) begin
                Data_memory[i] = i;
		end	
			end
	
    // Clock generation
    initial begin
        clk = 0;
		#600
		$finish;
    end
	always #5 clk = ~clk;// Clock generation
	//Instruction_memory[0] =16'b 0000110100010001;//add r1, r2, r3
	//Instruction_memory[0] =16'b0001100100110010;// sub r3, r2, r6
	//Instruction_memory[0] =16'b0001011000110000;// and r3, r4, r5
    //Instruction_memory[0] =16'b1111101000100100;// andi r1, r2, 31
	//Instruction_memory[0] =16'b0010000100100011;// addi r1, r1, 4
	//Instruction_memory[0] =16'b0000101000100101;// lw r1, r2, 1 
	//Instruction_memory[0] =16'b0000101000100110;// lbu r1, r2, 1 
	//Instruction_memory[0] =16'b0000101000110110;// lbs r1, r2, 1 
	//Instruction_memory[0] =16'b0000101000100111;// sw r1, r2, 1
	//Instruction_memory[0] =16'b0001101001101000;// BGT r3, r2, 3
	//Instruction_memory[0] =16'b0001101001101001;// BLT r3, r2, 3
	//Instruction_memory[0] =16'b0001101001101010;// BEQ r3, r2, 3
	//Instruction_memory[0] =16'b0001101001101011;// BNE r3, r2, 3
	//Instruction_memory[0] =16'b0000000010101100;// JMP 10
	//Instruction_memory[0] =16'b0000000010101101;// CALL 10
	//Instruction_memory[0] =16'b0000000000001110;// RET
	//Instruction_memory[0] =16'b0000011110111111;// SV r3, 15
	// Abbas Nassar-Mohammad Ataya-Ghassan Qandeel
    initial begin  
    	Instruction_memory[0] =16'b0000110100010001;//add r1, r2, r3
		Instruction_memory[1] =16'b0001011000110000;// and r3, r4, r5
		Instruction_memory[2] =16'b0000101000100101;// lw r1, r2, 1
		Instruction_memory[3] =16'b0000001001101000;// BGT r3, r2, 0
		Instruction_memory[4] =16'b0000011110111111;// SV r3, 15
		Instruction_memory[5] =16'b1111101000100100;// andi r1, r2, 31
		Instruction_memory[6] =16'b0001100100110010;// sub r3, r2, r6
		Instruction_memory[7] =16'b0000000000101101;// CALL 2
		Instruction_memory[8] =16'b0000101000100110;// lbu r1, r2, 1
		Instruction_memory[9] =16'b0000000000001110;// RET
		Instruction_memory[10] =16'b0000101000100111;// sw r1, r2, 1
	end
	
	initial	 
		
		begin
			$monitor("Time: %d, PC: %b, Instruction: %b, Opcode: %b, Stage: %b, PCsrc: %b", $time, PC, current_instruction, Opcode, Stage, PCsrc);
		end

endmodule 		