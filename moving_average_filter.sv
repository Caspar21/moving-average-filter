/*---------------------------------------------------------------------------------------------------------------------
Moving average filter for IEEE 1588

Function: make sure the correction value is accurate and stable
Author: Caspar Chen
E-mail: caspar_chen@pegatroncorp.com
Date:20200507

Modification History:
Data			By 			Version		 Change Description
=================================================================================================================


--------------------------------------------------------------------------------------------------------------------*/

//`timescale 1ns/1ns
module moving_average_filter#(

	 parameter TOD_WIDTH = 32
	 
)(
    input                             clk
	,input                             rst_n
	,input                             in_sop
	,input                             in_valid
	,input                             in_ready
	,input logic  [(TOD_WIDTH-1):0]   in_data
	,output logic [(TOD_WIDTH-1):0]   out_data

);

	localparam AVG_NUMBER     = 128;
	localparam INITIAL_VALUE  = 32'b0;
	localparam COUNTER_LENGTH = 8;

	logic [(TOD_WIDTH-1):0]     residence_average[1:0];
	logic [(TOD_WIDTH-1):0]     residence_temp[(AVG_NUMBER-1):0];
	logic [(COUNTER_LENGTH-1):0] avg_cnt;

	wire  [(TOD_WIDTH-1):0]     residence_stage[7:0];
	
	assign residence_stage[0] = residence_temp[0]+residence_temp[AVG_NUMBER-127]+residence_temp[AVG_NUMBER-126]+residence_temp[AVG_NUMBER-125]+residence_temp[AVG_NUMBER-124]+residence_temp[AVG_NUMBER-123]+residence_temp[AVG_NUMBER-122]+residence_temp[AVG_NUMBER-121]+residence_temp[AVG_NUMBER-120]+residence_temp[AVG_NUMBER-119]+residence_temp[AVG_NUMBER-118]+residence_temp[AVG_NUMBER-117]+residence_temp[AVG_NUMBER-116]+residence_temp[AVG_NUMBER-115]+residence_temp[AVG_NUMBER-114]+residence_temp[AVG_NUMBER-113];
	assign residence_stage[1] = residence_temp[AVG_NUMBER-112]+residence_temp[AVG_NUMBER-111]+residence_temp[AVG_NUMBER-110]+residence_temp[AVG_NUMBER-109]+residence_temp[AVG_NUMBER-108]+residence_temp[AVG_NUMBER-107]+residence_temp[AVG_NUMBER-106]+residence_temp[AVG_NUMBER-105]+residence_temp[AVG_NUMBER-104]+residence_temp[AVG_NUMBER-103]+residence_temp[AVG_NUMBER-102]+residence_temp[AVG_NUMBER-101]+residence_temp[AVG_NUMBER-100]+residence_temp[AVG_NUMBER-99]+residence_temp[AVG_NUMBER-98]+residence_temp[AVG_NUMBER-97];
	assign residence_stage[2] = residence_temp[AVG_NUMBER-96]+residence_temp[AVG_NUMBER-95]+residence_temp[AVG_NUMBER-94]+residence_temp[AVG_NUMBER-93]+residence_temp[AVG_NUMBER-92]+residence_temp[AVG_NUMBER-91]+residence_temp[AVG_NUMBER-90]+residence_temp[AVG_NUMBER-89]+residence_temp[AVG_NUMBER-88]+residence_temp[AVG_NUMBER-87]+residence_temp[AVG_NUMBER-86]+residence_temp[AVG_NUMBER-85]+residence_temp[AVG_NUMBER-84]+residence_temp[AVG_NUMBER-83]+residence_temp[AVG_NUMBER-82]+residence_temp[AVG_NUMBER-81];
	assign residence_stage[3] = residence_temp[AVG_NUMBER-80]+residence_temp[AVG_NUMBER-79]+residence_temp[AVG_NUMBER-78]+residence_temp[AVG_NUMBER-77]+residence_temp[AVG_NUMBER-76]+residence_temp[AVG_NUMBER-75]+residence_temp[AVG_NUMBER-74]+residence_temp[AVG_NUMBER-73]+residence_temp[AVG_NUMBER-72]+residence_temp[AVG_NUMBER-71]+residence_temp[AVG_NUMBER-70]+residence_temp[AVG_NUMBER-69]+residence_temp[AVG_NUMBER-68]+residence_temp[AVG_NUMBER-67]+residence_temp[AVG_NUMBER-66]+residence_temp[AVG_NUMBER-65];
	assign residence_stage[4] = residence_temp[AVG_NUMBER-64]+residence_temp[AVG_NUMBER-63]+residence_temp[AVG_NUMBER-62]+residence_temp[AVG_NUMBER-61]+residence_temp[AVG_NUMBER-60]+residence_temp[AVG_NUMBER-59]+residence_temp[AVG_NUMBER-58]+residence_temp[AVG_NUMBER-57]+residence_temp[AVG_NUMBER-56]+residence_temp[AVG_NUMBER-55]+residence_temp[AVG_NUMBER-54]+residence_temp[AVG_NUMBER-53]+residence_temp[AVG_NUMBER-52]+residence_temp[AVG_NUMBER-51]+residence_temp[AVG_NUMBER-50]+residence_temp[AVG_NUMBER-49];
	assign residence_stage[5] = residence_temp[AVG_NUMBER-48]+residence_temp[AVG_NUMBER-47]+residence_temp[AVG_NUMBER-46]+residence_temp[AVG_NUMBER-45]+residence_temp[AVG_NUMBER-44]+residence_temp[AVG_NUMBER-43]+residence_temp[AVG_NUMBER-42]+residence_temp[AVG_NUMBER-41]+residence_temp[AVG_NUMBER-40]+residence_temp[AVG_NUMBER-39]+residence_temp[AVG_NUMBER-38]+residence_temp[AVG_NUMBER-37]+residence_temp[AVG_NUMBER-36]+residence_temp[AVG_NUMBER-35]+residence_temp[AVG_NUMBER-34]+residence_temp[AVG_NUMBER-33];
	assign residence_stage[6] = residence_temp[AVG_NUMBER-32]+residence_temp[AVG_NUMBER-31]+residence_temp[AVG_NUMBER-30]+residence_temp[AVG_NUMBER-29]+residence_temp[AVG_NUMBER-28]+residence_temp[AVG_NUMBER-27]+residence_temp[AVG_NUMBER-26]+residence_temp[AVG_NUMBER-25]+residence_temp[AVG_NUMBER-24]+residence_temp[AVG_NUMBER-23]+residence_temp[AVG_NUMBER-22]+residence_temp[AVG_NUMBER-21]+residence_temp[AVG_NUMBER-20]+residence_temp[AVG_NUMBER-19]+residence_temp[AVG_NUMBER-18]+residence_temp[AVG_NUMBER-17];
	assign residence_stage[7] = residence_temp[AVG_NUMBER-16]+residence_temp[AVG_NUMBER-15]+residence_temp[AVG_NUMBER-14]+residence_temp[AVG_NUMBER-13]+residence_temp[AVG_NUMBER-12]+residence_temp[AVG_NUMBER-11]+residence_temp[AVG_NUMBER-10]+residence_temp[AVG_NUMBER-9]+residence_temp[AVG_NUMBER-8]+residence_temp[AVG_NUMBER-7]+residence_temp[AVG_NUMBER-6]+residence_temp[AVG_NUMBER-5]+residence_temp[AVG_NUMBER-4]+residence_temp[AVG_NUMBER-3]+residence_temp[AVG_NUMBER-2]+residence_temp[AVG_NUMBER-1];
//counter for average number, max is 128, min is 1	
	always@(posedge clk or negedge rst_n) begin
	    if(!rst_n) begin
		    avg_cnt <= 1'b1;
	    end 
		 else if(in_sop && in_valid && in_ready) begin
	  	    avg_cnt <= (avg_cnt == AVG_NUMBER) ? avg_cnt : avg_cnt + 1'b1;
	    end
	end
//residence_temp
   always@(posedge clk or negedge rst_n) begin
	   if(!rst_n) begin
			residence_temp[AVG_NUMBER-127] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-126] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-125] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-124] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-123] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-122] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-121] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-120] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-119] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-118] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-117] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-116] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-115] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-114] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-113] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-112] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-111] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-110] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-109] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-108] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-107] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-106] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-105] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-104] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-103] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-102] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-101] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-100] <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-99]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-98]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-97]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-96]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-95]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-94]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-93]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-92]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-91]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-90]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-89]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-88]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-87]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-86]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-85]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-84]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-83]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-82]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-81]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-80]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-79]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-78]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-77]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-76]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-75]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-74]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-73]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-72]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-71]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-70]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-69]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-68]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-67]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-66]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-65]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-64]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-63]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-62]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-61]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-60]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-59]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-58]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-57]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-56]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-55]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-54]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-53]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-52]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-51]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-50]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-49]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-48]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-47]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-46]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-45]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-44]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-43]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-42]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-41]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-40]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-39]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-38]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-37]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-36]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-35]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-34]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-33]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-32]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-31]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-30]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-29]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-28]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-27]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-26]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-25]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-24]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-23]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-22]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-21]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-20]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-19]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-18]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-17]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-16]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-15]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-14]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-13]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-12]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-11]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-10]  <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-9]   <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-8]   <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-7]   <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-6]   <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-5]   <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-4]   <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-3]   <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-2]   <= INITIAL_VALUE;
			residence_temp[AVG_NUMBER-1]   <= INITIAL_VALUE;
			residence_temp[0]              <= INITIAL_VALUE;
			residence_average[0]           <= INITIAL_VALUE;
			residence_average[1]           <= INITIAL_VALUE;
      end 
		else if(in_sop && in_valid && in_ready) begin
			residence_temp[AVG_NUMBER-127] <= residence_temp[0];
			residence_temp[AVG_NUMBER-126] <= residence_temp[AVG_NUMBER-127];
			residence_temp[AVG_NUMBER-125] <= residence_temp[AVG_NUMBER-126];
			residence_temp[AVG_NUMBER-124] <= residence_temp[AVG_NUMBER-125];
			residence_temp[AVG_NUMBER-123] <= residence_temp[AVG_NUMBER-124];
			residence_temp[AVG_NUMBER-122] <= residence_temp[AVG_NUMBER-123];
			residence_temp[AVG_NUMBER-121] <= residence_temp[AVG_NUMBER-122];
			residence_temp[AVG_NUMBER-120] <= residence_temp[AVG_NUMBER-121];
			residence_temp[AVG_NUMBER-119] <= residence_temp[AVG_NUMBER-120];
			residence_temp[AVG_NUMBER-118] <= residence_temp[AVG_NUMBER-119];
			residence_temp[AVG_NUMBER-117] <= residence_temp[AVG_NUMBER-118];
			residence_temp[AVG_NUMBER-116] <= residence_temp[AVG_NUMBER-117];
			residence_temp[AVG_NUMBER-115] <= residence_temp[AVG_NUMBER-116];
			residence_temp[AVG_NUMBER-114] <= residence_temp[AVG_NUMBER-115];
			residence_temp[AVG_NUMBER-113] <= residence_temp[AVG_NUMBER-114];
			residence_temp[AVG_NUMBER-112] <= residence_temp[AVG_NUMBER-113];
			residence_temp[AVG_NUMBER-111] <= residence_temp[AVG_NUMBER-112];
			residence_temp[AVG_NUMBER-110] <= residence_temp[AVG_NUMBER-111];
			residence_temp[AVG_NUMBER-109] <= residence_temp[AVG_NUMBER-110];
			residence_temp[AVG_NUMBER-108] <= residence_temp[AVG_NUMBER-109];
			residence_temp[AVG_NUMBER-107] <= residence_temp[AVG_NUMBER-108];
			residence_temp[AVG_NUMBER-106] <= residence_temp[AVG_NUMBER-107];
			residence_temp[AVG_NUMBER-105] <= residence_temp[AVG_NUMBER-106];
			residence_temp[AVG_NUMBER-104] <= residence_temp[AVG_NUMBER-105];
			residence_temp[AVG_NUMBER-103] <= residence_temp[AVG_NUMBER-104];
			residence_temp[AVG_NUMBER-102] <= residence_temp[AVG_NUMBER-103];
			residence_temp[AVG_NUMBER-101] <= residence_temp[AVG_NUMBER-102];
			residence_temp[AVG_NUMBER-100] <= residence_temp[AVG_NUMBER-101];
			residence_temp[AVG_NUMBER-99]  <= residence_temp[AVG_NUMBER-100];
			residence_temp[AVG_NUMBER-98]  <= residence_temp[AVG_NUMBER-99];
			residence_temp[AVG_NUMBER-97]  <= residence_temp[AVG_NUMBER-98];
			residence_temp[AVG_NUMBER-96]  <= residence_temp[AVG_NUMBER-97];
			residence_temp[AVG_NUMBER-95]  <= residence_temp[AVG_NUMBER-96];
			residence_temp[AVG_NUMBER-94]  <= residence_temp[AVG_NUMBER-95];
			residence_temp[AVG_NUMBER-93]  <= residence_temp[AVG_NUMBER-94];
			residence_temp[AVG_NUMBER-92]  <= residence_temp[AVG_NUMBER-93];
			residence_temp[AVG_NUMBER-91]  <= residence_temp[AVG_NUMBER-92];
			residence_temp[AVG_NUMBER-90]  <= residence_temp[AVG_NUMBER-91];
			residence_temp[AVG_NUMBER-89]  <= residence_temp[AVG_NUMBER-90];
			residence_temp[AVG_NUMBER-88]  <= residence_temp[AVG_NUMBER-89];
			residence_temp[AVG_NUMBER-87]  <= residence_temp[AVG_NUMBER-88];
			residence_temp[AVG_NUMBER-86]  <= residence_temp[AVG_NUMBER-87];
			residence_temp[AVG_NUMBER-85]  <= residence_temp[AVG_NUMBER-86];
			residence_temp[AVG_NUMBER-84]  <= residence_temp[AVG_NUMBER-85];
			residence_temp[AVG_NUMBER-83]  <= residence_temp[AVG_NUMBER-84];
			residence_temp[AVG_NUMBER-82]  <= residence_temp[AVG_NUMBER-83];
			residence_temp[AVG_NUMBER-81]  <= residence_temp[AVG_NUMBER-82];
			residence_temp[AVG_NUMBER-80]  <= residence_temp[AVG_NUMBER-81];
			residence_temp[AVG_NUMBER-79]  <= residence_temp[AVG_NUMBER-80];
			residence_temp[AVG_NUMBER-78]  <= residence_temp[AVG_NUMBER-79];
			residence_temp[AVG_NUMBER-77]  <= residence_temp[AVG_NUMBER-78];
			residence_temp[AVG_NUMBER-76]  <= residence_temp[AVG_NUMBER-77];
			residence_temp[AVG_NUMBER-75]  <= residence_temp[AVG_NUMBER-76];
			residence_temp[AVG_NUMBER-74]  <= residence_temp[AVG_NUMBER-75];
			residence_temp[AVG_NUMBER-73]  <= residence_temp[AVG_NUMBER-74];
			residence_temp[AVG_NUMBER-72]  <= residence_temp[AVG_NUMBER-73];
			residence_temp[AVG_NUMBER-71]  <= residence_temp[AVG_NUMBER-72];
			residence_temp[AVG_NUMBER-70]  <= residence_temp[AVG_NUMBER-71];
			residence_temp[AVG_NUMBER-69]  <= residence_temp[AVG_NUMBER-70];
			residence_temp[AVG_NUMBER-68]  <= residence_temp[AVG_NUMBER-69];
			residence_temp[AVG_NUMBER-67]  <= residence_temp[AVG_NUMBER-68];
			residence_temp[AVG_NUMBER-66]  <= residence_temp[AVG_NUMBER-67];
			residence_temp[AVG_NUMBER-65]  <= residence_temp[AVG_NUMBER-66];
			residence_temp[AVG_NUMBER-64]  <= residence_temp[AVG_NUMBER-65];
			residence_temp[AVG_NUMBER-63]  <= residence_temp[AVG_NUMBER-64];
			residence_temp[AVG_NUMBER-62]  <= residence_temp[AVG_NUMBER-63];
			residence_temp[AVG_NUMBER-61]  <= residence_temp[AVG_NUMBER-62];
			residence_temp[AVG_NUMBER-60]  <= residence_temp[AVG_NUMBER-61];
			residence_temp[AVG_NUMBER-59]  <= residence_temp[AVG_NUMBER-60];
			residence_temp[AVG_NUMBER-58]  <= residence_temp[AVG_NUMBER-59];
			residence_temp[AVG_NUMBER-57]  <= residence_temp[AVG_NUMBER-58];
			residence_temp[AVG_NUMBER-56]  <= residence_temp[AVG_NUMBER-57];
			residence_temp[AVG_NUMBER-55]  <= residence_temp[AVG_NUMBER-56];
			residence_temp[AVG_NUMBER-54]  <= residence_temp[AVG_NUMBER-55];
			residence_temp[AVG_NUMBER-53]  <= residence_temp[AVG_NUMBER-54];
			residence_temp[AVG_NUMBER-52]  <= residence_temp[AVG_NUMBER-53];
			residence_temp[AVG_NUMBER-51]  <= residence_temp[AVG_NUMBER-52];
			residence_temp[AVG_NUMBER-50]  <= residence_temp[AVG_NUMBER-51];
			residence_temp[AVG_NUMBER-49]  <= residence_temp[AVG_NUMBER-50];
			residence_temp[AVG_NUMBER-48]  <= residence_temp[AVG_NUMBER-49];
			residence_temp[AVG_NUMBER-47]  <= residence_temp[AVG_NUMBER-48];
			residence_temp[AVG_NUMBER-46]  <= residence_temp[AVG_NUMBER-47];
			residence_temp[AVG_NUMBER-45]  <= residence_temp[AVG_NUMBER-46];
			residence_temp[AVG_NUMBER-44]  <= residence_temp[AVG_NUMBER-45];
			residence_temp[AVG_NUMBER-43]  <= residence_temp[AVG_NUMBER-44];
			residence_temp[AVG_NUMBER-42]  <= residence_temp[AVG_NUMBER-43];
			residence_temp[AVG_NUMBER-41]  <= residence_temp[AVG_NUMBER-42];
			residence_temp[AVG_NUMBER-40]  <= residence_temp[AVG_NUMBER-41];
			residence_temp[AVG_NUMBER-39]  <= residence_temp[AVG_NUMBER-40];
			residence_temp[AVG_NUMBER-38]  <= residence_temp[AVG_NUMBER-39];
			residence_temp[AVG_NUMBER-37]  <= residence_temp[AVG_NUMBER-38];
			residence_temp[AVG_NUMBER-36]  <= residence_temp[AVG_NUMBER-37];
			residence_temp[AVG_NUMBER-35]  <= residence_temp[AVG_NUMBER-36];
			residence_temp[AVG_NUMBER-34]  <= residence_temp[AVG_NUMBER-35];
			residence_temp[AVG_NUMBER-33]  <= residence_temp[AVG_NUMBER-34];
			residence_temp[AVG_NUMBER-32]  <= residence_temp[AVG_NUMBER-33];
			residence_temp[AVG_NUMBER-31]  <= residence_temp[AVG_NUMBER-32];
			residence_temp[AVG_NUMBER-30]  <= residence_temp[AVG_NUMBER-31];
			residence_temp[AVG_NUMBER-29]  <= residence_temp[AVG_NUMBER-30];
			residence_temp[AVG_NUMBER-28]  <= residence_temp[AVG_NUMBER-29];
			residence_temp[AVG_NUMBER-27]  <= residence_temp[AVG_NUMBER-28];
			residence_temp[AVG_NUMBER-26]  <= residence_temp[AVG_NUMBER-27];
			residence_temp[AVG_NUMBER-25]  <= residence_temp[AVG_NUMBER-26];
			residence_temp[AVG_NUMBER-24]  <= residence_temp[AVG_NUMBER-25];
			residence_temp[AVG_NUMBER-23]  <= residence_temp[AVG_NUMBER-24];
			residence_temp[AVG_NUMBER-22]  <= residence_temp[AVG_NUMBER-23];
			residence_temp[AVG_NUMBER-21]  <= residence_temp[AVG_NUMBER-22];
			residence_temp[AVG_NUMBER-20]  <= residence_temp[AVG_NUMBER-21];
			residence_temp[AVG_NUMBER-19]  <= residence_temp[AVG_NUMBER-20];
			residence_temp[AVG_NUMBER-18]  <= residence_temp[AVG_NUMBER-19];
			residence_temp[AVG_NUMBER-17]  <= residence_temp[AVG_NUMBER-18];
			residence_temp[AVG_NUMBER-16]  <= residence_temp[AVG_NUMBER-17];
			residence_temp[AVG_NUMBER-15]  <= residence_temp[AVG_NUMBER-16];
			residence_temp[AVG_NUMBER-14]  <= residence_temp[AVG_NUMBER-15];
			residence_temp[AVG_NUMBER-13]  <= residence_temp[AVG_NUMBER-14];
			residence_temp[AVG_NUMBER-12]  <= residence_temp[AVG_NUMBER-13];
			residence_temp[AVG_NUMBER-11]  <= residence_temp[AVG_NUMBER-12];
			residence_temp[AVG_NUMBER-10]  <= residence_temp[AVG_NUMBER-11];
			residence_temp[AVG_NUMBER-9]   <= residence_temp[AVG_NUMBER-10];
			residence_temp[AVG_NUMBER-8]   <= residence_temp[AVG_NUMBER-9];
			residence_temp[AVG_NUMBER-7]   <= residence_temp[AVG_NUMBER-8];
			residence_temp[AVG_NUMBER-6]   <= residence_temp[AVG_NUMBER-7];
			residence_temp[AVG_NUMBER-5]   <= residence_temp[AVG_NUMBER-6];
			residence_temp[AVG_NUMBER-4]   <= residence_temp[AVG_NUMBER-5];
			residence_temp[AVG_NUMBER-3]   <= residence_temp[AVG_NUMBER-4];
			residence_temp[AVG_NUMBER-2]   <= residence_temp[AVG_NUMBER-3];
			residence_temp[AVG_NUMBER-1]   <= residence_temp[AVG_NUMBER-2];
			residence_temp[0]              <= in_data;
			residence_average[0]           <= (residence_stage[0]+residence_stage[1]+residence_stage[2]+residence_stage[3])>>6;
			residence_average[1]           <= (residence_stage[0]+residence_stage[1]+residence_stage[2]+residence_stage[3]+residence_stage[4]+residence_stage[5]+residence_stage[6]+residence_stage[7])>>7;
      end
   end
//average residence time 
	always@(posedge clk) begin
      if(in_sop && in_valid && in_ready) begin
		    if(avg_cnt == AVG_NUMBER) begin
		       out_data <= residence_average[1];
	       end 
		    else if (avg_cnt < AVG_NUMBER && avg_cnt >= 8'h40) begin
		       out_data <= residence_average[0];
		    end
			 else begin
			    out_data <= in_data;
			 end
	   end
		else begin
		   out_data <= in_data;
	   end
	end

endmodule