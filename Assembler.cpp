#include <iostream>
#include <sstream>
#include <fstream>
#include <string>
#include <iterator>
#include <map>
using namespace std;

struct MemEntry{
	int index;		// Location in memory
	string value;	// Value of instruction in binary stored 16 bit by 16 bit
};

// Eight 16-bit general purpose registers translated to binary
string Get_Regitser_Index(string Reg_Name){
	if      (Reg_Name == "R0" || Reg_Name == "r0") return "000";
	else if (Reg_Name == "R1" || Reg_Name == "r1") return "001";
	else if (Reg_Name == "R2" || Reg_Name == "r2") return "010";
	else if (Reg_Name == "R3" || Reg_Name == "r3") return "011";
	else if (Reg_Name == "R4" || Reg_Name == "r4") return "100";
	else if (Reg_Name == "R5" || Reg_Name == "r5") return "101";
	else if (Reg_Name == "R6" || Reg_Name == "r6") return "110";
	else if (Reg_Name == "R7" || Reg_Name == "r7") return "111";
	else return "Invalid";
}

string HexToBin(string hexdec){
    int i = 0;
	string to_binary = "";
	string concated = "";
	while (hexdec[i]){
		switch (hexdec[i]){
		case '0':
			concated = "0000";
			break;
		case '1':
			concated = "0001";
			break;
		case '2':
			concated = "0010";
			break;
		case '3':
			concated = "0011";
			break;
		case '4':
			concated = "0100";
			break;
		case '5':
			concated = "0101";
			break;
		case '6':
			concated = "0110";
			break;
		case '7':
			concated = "0111";
			break;
		case '8':
			concated = "1000";
			break;
		case '9':
			concated = "1001";
			break;
		case 'A':
		case 'a':
			concated = "1010";
			break;
		case 'B':
		case 'b':
			concated = "1011";
			break;
		case 'C':
		case 'c':
			concated = "1100";
			break;
		case 'D':
		case 'd':
			concated = "1101";
			break;
		case 'E':
		case 'e':
			concated = "1110";
			break;
		case 'F':
		case 'f':
			concated = "1111";
			break;
		default:
			return "Invalid";
		}
		i++;
		to_binary = to_binary + concated;
	}
	while (i < 4){
		to_binary = "0000" + to_binary;
		i++;
	}
	if (i == 4)
		return to_binary;
	else
		return "Invalid";
}

// Operands[0]
// Operands[1]
// Operands[2]
// D, T, S, I
// Here we have at most 3 operands (R destination, R target, R source)
// we take the instruction and return the operands of it and the opcode (first 2 bits for family and last 3 bits for operation)
string To_OPcode(string command, string *Operands){
	if (command == "NOP"){
		Operands[0] = "";
		Operands[1] = "";
		Operands[2] = "";
		return "00000";
	}
	else if (command == "SETC"){
		Operands[0] = "";
		Operands[1] = "";
		Operands[2] = "";
        return "00001";
	}
    else if (command == "CLRC"){
		Operands[0] = "";
		Operands[1] = "";
		Operands[2] = "";
        return "00010";
	}
	else if (command == "NOT"){
		Operands[0] = "D";
		Operands[1] = "S";
		Operands[2] = "";
        return "00011";
	}
	else if (command == "INC"){
		Operands[0] = "D";
		Operands[1] = "S";
		Operands[2] = "";
        return "00100";
	}
	else if (command == "DEC"){
		Operands[0] = "D";
		Operands[1] = "S";
		Operands[2] = "";
        return "00101";
	}
	else if (command == "IN"){
		Operands[0] = "D";
		Operands[1] = "";
		Operands[2] = "";
        return "00110";
	}
	else if (command == "OUT"){
		Operands[0] = "S";
		Operands[1] = "";
		Operands[2] = "";
        return "00111";
	}
    /******************************/
	else if (command == "MOV"){
		Operands[0] = "D";
		Operands[1] = "S";
		Operands[2] = "";
        return "01000";
	}
	else if (command == "OR"){
		Operands[0] = "D";
		Operands[1] = "S";
		Operands[2] = "T";
        return "01001";
	}
	else if (command == "ADD"){
		Operands[0] = "D";
		Operands[1] = "S";
		Operands[2] = "T";
        return "01010";
	}
	else if (command == "SUB"){
		Operands[0] = "D";
		Operands[1] = "T";
		Operands[2] = "S";
        return "01011";	
    }
	else if (command == "AND"){
		Operands[0] = "D";
		Operands[1] = "S";
		Operands[2] = "T";
        return "01100";
	}
	else if (command == "IADD"){
		Operands[0] = "D";
		Operands[1] = "S";
		Operands[2] = "I";
        return "01101";
	}
    /******************************/
	else if (command == "PUSH"){
		Operands[0] = "S";
		Operands[1] = "";
		Operands[2] = "";
        return "10000";
	}
	else if (command == "POP"){
		Operands[0] = "D";
		Operands[1] = "";
		Operands[2] = "";
        return "10001";
	}
	else if (command == "LDM"){
		Operands[0] = "D";
		Operands[1] = "I";
		Operands[2] = "";
        return "10010";
	}
	else if (command == "LDD"){
		Operands[0] = "D";
		Operands[1] = "S";
		Operands[2] = "";
        return "10011";
	}
	else if (command == "STD"){
		Operands[0] = "T";
		Operands[1] = "S";
		Operands[2] = "";
        return "10100";
	}
    /******************************/
    else if (command == "CALL"){
		Operands[0] = "D";
		Operands[1] = "";
		Operands[2] = "";
        return "11000";
	}
    else if (command == "RET"){
		Operands[0] = "";
		Operands[1] = "";
		Operands[2] = "";
        return "11001";
	}
	else if (command == "JZ"){
		Operands[0] = "D";
		Operands[1] = "";
		Operands[2] = "";
        return "11010";
	}
	else if (command == "JC"){
		Operands[0] = "D";
		Operands[1] = "";
		Operands[2] = "";
        return "11011";
	}
	else if (command == "JMP"){
		Operands[0] = "D";
		Operands[1] = "";
		Operands[2] = "";
        return "11100";
	}
	else if (command == "RTI"){
		Operands[0] = "";
		Operands[1] = "";
		Operands[2] = "";
        return "11101";
	}
	else{
		Operands[0] = "";
		Operands[1] = "";
		Operands[2] = "";
        return "Invalid";
	}
}

// This function reads a lines from the input file and 
// returns -1 for wrong syntax line,
// 0 for empty or commented lines,
// 1 for meaningful lines
int readLine(ifstream &inputFile, string *words){
	char nextChar;
	string line;
	int counter = 0;
	getline(inputFile, line, '\n');
	while (!line.empty()){
		nextChar = line.front();
		line.erase(0, 1);
		// Skip if comment line
		if (nextChar == '#')
			break;
		// Skip white spaces
		if (counter != 0 && (nextChar == ' ' || nextChar == '\t')){
			nextChar = line.front();
			while (!line.empty()){
				if (nextChar == '#')
					break;
				else if (nextChar != ' ' && nextChar != '\t')
					return -1;
				line.erase(0, 1);
				nextChar = line.front();
			}
		}
		// Here we consider a indentation in the beginning of the line
		else if (counter == 0 && (nextChar == ' ' || nextChar == '\t')){
			if (!words[0].empty())
				counter++;
			nextChar = line.front();
			while (!line.empty()){
				if (isalnum(nextChar) || nextChar == '#')
					break;
				else if (nextChar != ' ' && nextChar != '\t')
					return -1;
				line.erase(0, 1);
				nextChar = line.front();
			}
		}
		// if we have one operand or two followed by a comma then we are expecting another operand
		else if ((counter == 1 || counter == 2) && nextChar == ','){
			if (!words[0].empty())
				counter++;
			nextChar = line.front();
			while (!line.empty()){
				if (isalnum(nextChar))
					break;
				else if (nextChar != ' ' && nextChar != '\t')
					return -1;
				line.erase(0, 1);
				nextChar = line.front();
			}
		}
		// If valid then add it to words
		else if (counter < 4 && (isalnum(nextChar) || nextChar == '.')){
			words[counter].push_back(nextChar);
		}
		else
			return -1;
	}
	if (words[0].empty())
		return 0;
	return 1;
}

// In this function we analyze the instruction
// returns -1 for wrong syntax instruction,
// 1 for meaningful instruction
int readIns(ifstream &inputFile, string *words, MemEntry &output)
{
	// Convert all words to upper case
	// we have maximum 4 words in each line
	for (int i = 0; i < 4; i++){
		for (int j = 0; j < words[i].length(); j++)
			words[i][j] = toupper(words[i][j]);
	}
	// Initialize all the instruction fields with dummy values
	string opcode, immediate = "", Rt = "000", Rs = "000", Rd = "000", unused ="0", isImm = "0";
	string operands[3];
	// Get the opcode
	opcode = To_OPcode(words[0], operands);
	if (opcode == "Invalid")
		return -1;

	for (int i = 0; i < 3; i++)
	{
        // Missmatch between operands and words (count of operands)
        // Example: ADD R1, 
		if (operands[i].empty() != words[i + 1].empty())
			return -1;
		// If register is used then get its index
		// Example: ADD R1, R2 (get index of R1 and R2)
		// ELSE if immediate is used then convert it to binary
		// Example: ADD R1, 0x10 (get index of R1 and convert 10 to binary)
		if (!operands[i].empty() && !words[i + 1].empty()){
			for (int j = 0; j < operands[i].length(); j++){
				if (operands[i][j] == 'S')
					Rs = Get_Regitser_Index(words[i + 1]);
				else if (operands[i][j] == 'D')
					Rd = Get_Regitser_Index(words[i + 1]);
				else if (operands[i][j] == 'T')
					Rt = Get_Regitser_Index(words[i + 1]);
				else if (operands[i][j] == 'I')
					immediate = HexToBin(words[i + 1]);
			}
		}
	}
	// If any of D, S, T, I is invalid then the instruction is invalid
	if (Rs == "Invalid" || Rd == "Invalid" || Rt == "Invalid" || immediate == "Invalid")
		return -1;
	// If the instruction use immediate then it's 32 bits instruction meaning we will store it in 2 memory locations 
	// If not then immediate will be empty string adding it wont affect the instruction and it will be stored in 1 memory location
	if(!immediate.empty()){
        cout << "immediate: " << immediate << endl;
        isImm = "1";
    }
    output.value = opcode + Rs + Rt + Rd + unused + isImm + immediate;
	return 1;
}

// Function that takes a string and returns the first number in it
void Get_Number(string str, string &number){
	number = "";
	for (int i = 0; i < str.length(); i++){
		if (isalnum(str[i]))
			number.push_back(str[i]);
		else
			return;
	}
}

// This function determines where will the instruction be stored in memory
// Returns -1 for wrong syntax instruction,
// 0 for empty or commented lines,
// 1 for meaningful instruction
int writeInMem(ifstream &inputFile, MemEntry &output, int &currentAddress, int &lineNum){
	// Parsing
	string words[4];
	int outcome;
	// Skip empty spaces (outcome == 0 means empty line or comment check "readLine" function)
	do{
		lineNum++;
		outcome = readLine(inputFile, words);
	} while (outcome == 0 && inputFile);
	// If we reached the end of the file then return 0
	if (!inputFile)
		return 0;
	// If we have a wrong syntax then return -1
	if (outcome == -1)
		return -1;
	// Convert all words to upper case
	for (int i = 0; i < 4; i++){
		for (int j = 0; j < words[i].length(); j++)
			words[i][j] = toupper(words[i][j]);
	}

	// If the instruction is ORG then we will change the current address
	if (words[0] == ".ORG")
	{
		stringstream ss;
		// Convert the address to hex
		ss << hex << words[1];
		// Store the address in currentAddress
		ss >> output.index;
		cout << "Instruction Index: " << output.index << endl;
		// ORG dosen't have ant operands but the address
		if (!words[2].empty() || !words[3].empty())
			return -1;
		// Get the number to store in memory if the address is 0 to 2
		if (output.index <= 2 && output.index >= 0){
			// Example: .ORG 0
			//  		20
			// This will store 20 in memory location 0
			string number;
			lineNum++;
			getline(inputFile, number, '\n');
			Get_Number(number, number);
			output.value = HexToBin(number);
			if (output.value == "Invalid")
				return -1;
			return 1;
		}
		// Else Is it meaningful instruction?
		else{
			string new_words[4];
			int outcome;
			do{
				lineNum++;
				outcome = readLine(inputFile, new_words);
			} while (outcome == 0 && inputFile);
			if (!inputFile)
				return 0;
			if (outcome == -1)
				return -1;
			if (readIns(inputFile, new_words, output) == -1)
				return -1;
			return 1;
		}
	}
    // In case we don't have ORG then we will store the instruction in the current address + 1
	else{
		output.index = currentAddress + 1;
		if (readIns(inputFile, words, output) == -1)
			return -1;
		return 1;
	}
}

// To run the program
// g++ Assembler.cpp -o Assembler.exe
// .\Assembler.exe TestCase.txt output.mem
int main(int argc, char *argv[])
{
	map<int, string> Memory;
	if (argc != 3){
		cout << "Invalid Inputs" << endl;
		return 0;
	}
	ifstream inputFile(argv[1]);
	if (!inputFile){
		cout << "Invalid Input File" << endl;
		return 0;
	}
	// Setting current address with any Hex value
	int currentAddress = 0x1000;
	int lineNum = 0;
    MemEntry output;
	while (inputFile){
		currentAddress = output.index;
        int state = writeInMem(inputFile, output, currentAddress, lineNum);
		if (state == 1){
			// Insert 16 bit always
			Memory.insert(pair<int, string>(output.index, output.value.substr(0,16)));
            // If its 32 bit then insert the other 16 bits
			if(output.value.length() > 16){
                output.index++;
			    Memory.insert(pair<int, string>(output.index, output.value.substr(16,16)));
            }
            cout << "At Index: " << output.index << ", Instruction: " << output.value << endl;
        }
		// This gets the line with the error
		else if (state == -1){
			cout << "Error at line " << lineNum << endl;
			inputFile.close();
			return 0;
		}
	}
	inputFile.close();
	ofstream outputFile;
	outputFile.open(argv[2]);
	if (!outputFile){
		cout << "Invalid Output File" << endl;
		outputFile.close();
		return 0;
	}
	map<int, string>::iterator itr = Memory.begin();
	outputFile 	<< "// memory data file (do not edit the following line - required for mem load use)" 
				<< endl << "// instance=/cpu/fetch1/line__56/Cache"
				<< endl << "// format=mti addressradix=d dataradix=b version=1.0 wordsperline=1"
				<< endl;
	for (itr; itr != Memory.end(); ++itr){
        outputFile << itr->first << ": " << itr->second /*<< " || Memory Location("<< itr->first << ")" */<< endl;
		map<int, string>::iterator itrNext = itr;
		++itrNext;
		if (itrNext->first == itr->first){
			cout << "Error, Two instructions in same address" << endl;
			outputFile.close();
			return 0;
		}
	}
	outputFile.close();
	return 0;
}