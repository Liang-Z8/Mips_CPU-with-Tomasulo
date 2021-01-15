// Add_ALUopcode
// `define ALUAdd 2'b00
// `define ALUSub 2'b01
// `define ALUAnd 2'b10
// `define ALUOr 2'b11
// `define ALUMultiple 2'b00
// `define ALUDivide 2'b01


//访存指令op，最高位代表访存信号，L0，W1
`define LW 4'b0001
`define SW 4'b1010

`define Addu  4'b0000   //r=a+b unsigned
`define Add  4'b0010   //r=a+b signed
`define Subu  4'b0001    //r=a-b unsigned
`define Sub  4'b0011    //r=a-b signed
`define And  4'b0100    //r=a&b
`define Or  4'b0101    //r=a|b
`define Xor  4'b0110    //r=a^b
`define Nor  4'b0111    //r=~(a|b)
`define Lui1  4'b1000    //r={b[15:0],16'b0}
`define Lui2  4'b1001    //r={b[15:0],16'b0}
`define Slt  4'b1011    //r=(a-b<0)?1:0 signed
`define Sltu  4'b1010    //r=(a-b<0)?1:0 unsigned
`define Sra  4'b1100    //r=b>>>a 
`define Sll  4'b1110    //r=b<<a
`define Srl  4'b1101    //r=b>>a

`define Mulu 4'b0001
`define Mul 4'b0010
`define Divu 4'b0011
`define Div 4'b0100



// ExtSel
`define ZesroExd 1'b0
`define SignExd 1'b1

// PCSrc
`define NextIns 2'b00
`define RelJmp 2'b01 //relative jump
`define AbsJmp 2'b10 //absolute jump
`define RsJmp 2'b11 // Jump to Rs, by JR instrustion

// for instruction
// op code
//load store
`define opLW 6'b100011

`define opSW 6'b101011

//RR
`define opRR 6'b000000
`define opRFormat 6'b000000
`define opADD 6'b000000
`define opSUB 6'b000000
`define opAND 6'b000000
`define opOR 6'b000000
`define opSLL 6'b000000
`define opSLT 6'b000000
`define opJR 6'b000000
`define opMULIU 6'b000000
`define opDIVU 6'b000000

//RI
`define opADDI 6'b001000
`define opADDIU 6'b001001
`define opLUI 6'b001111
`define opORI 6'b001101
`define opSLTI 6'b001010
`define opSLTIU 6'b001011
`define opXORI 6'b001110

`define opORI 6'b001101
`define opSW 6'b101011
`define opLW 6'b100011
`define opBEQ 6'b000100
`define opBNE 6'b000101
`define opBGTZ 6'b000111
`define opJ 6'b000010
`define opJAL 6'b011000

`define opHALT 6'b111111
// func code
`define funcADD 6'b100000
`define funcADDU 6'b100001 
`define funcAND 6'b100100
`define funcDIV 6'b011010
`define funcDIVU 6'b011011
`define funcMUL 6'b011000 
`define funcMULU 6'b001011
`define funcNOR 6'b100111
`define funcOR 6'b100101
`define funcSLL 6'b000100
`define funcSLT 6'b101010
`define funcSLTU 6'b101011
`define funcSRA 6'b000011
//`define funcSRAV 6'b000111
`define funcSRL 6'b000010 
`define funcXOR 6'b100110
`define funcSUB 6'b100010
`define funcSUBU 6'b100011
//J
`define funcJR 6'b000001

// ALU state
`define sIdle 0
`define sPremitiveIns 2'b01
`define sInverse 2'b10 // for Inverse
`define sMAdd 2'b11 // for Minus Add

`define sMul32 3'b001
`define sMul16 3'b010 
`define sMul8 3'b011
`define sMul4 3'b100
`define sMul2 3'b101
`define sMulAnswer 3'b110

`define sFPMatchExp 2'b01
`define sFPSumUp 2'b10
`define sFPNorm 2'b11

`define sWorking 1'b1

// for RAMStation
`define opLoad 2'b01
`define opStore 2'b00

// Labels code
// dd-dd
// category - id
`define Add0 5'b001_00 
`define Add1 5'b001_01 
`define Add2 5'b001_10
`define MUL0 5'b010_00 
`define MUL1 5'b010_01 
`define MUL2 5'b010_10
`define Mem0 5'b100_00 
`define Mem1 5'b100_01 
`define Mem2 5'b100_10 
// `define DIV0 4'b10_01 
// `define DIV1 4'b10_10 
// `define DIV2 4'b10_11 
// `define Logic0 4'b011_00 
// `define Logic1 4'b011_01
// `define Logic2 4'b011_10


//reservation category 
`define MemLst 3'b100
`define MemSst 3'b101 
`define Addst 3'b001
`define Mulst 3'b010
//`define Divst 3'b011
// `define logicst 3'b011 

