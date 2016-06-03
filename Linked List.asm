	.data
strNum: .asciiz "Enter a list of numbers: "
strPush:.asciiz "Push => "
strPop:	.asciiz "Pop => "
strGuion: .asciiz " - "
strOutOfMemory: .asciiz "Out of memory"
	.text

#typedef struct _node_t {
    #struct _node_t *next;      => s0
    #int val;              	=> s1
#} node_t;

#main(){
	#node_t *top //Create node
	
	#int n = readln()
	#while(n != 0){
		#push(top , n);
		#readln(n)
	#}
	#pop(top);
	
	#print(top);
#}

## s0 => top
## s1 => val				
main:
	#Print insert number
	li $v0, 4
	la $a0, strNum
	syscall
	
	#Read the number and save it in s1
	li $v0, 5
	syscall
	move $a1, $v0
	
	#Create the node
	li $a0, 0
	move $s1, $a1
	jal Create
	move $s0, $v0
	#Print
	la $a0, strPush
	li $v0, 4
	syscall
	move $a0, $s0
	jal Print
	loop:
		#Read the numbers
		li $v0, 5
		syscall
		move $s1, $v0
		
		beqz $s1, finishWhile	# Check if the number is bigger than 0
	
		move $a0, $s0
		move $a1, $s1
		jal Push
		move $s0, $v0
		
		la $a0, strPush
		li $v0, 4
		syscall
		move $a0, $s0
		jal Print
		b loop
		
	finishWhile:
		#Pop
		li $v0, 4
		la $a0, strPop
		syscall
		move $a0, $s0
		jal Pop
		move $s0, $v0
		#Print
		move $a0, $s0
		jal Print
		move $s0, $v0
	
		j finishProgram
#endMain

## s0 => top
## s1 => val
Create:
	subu $sp, $sp, 32
	sw $ra, 28($sp)
	sw $fp, 24($sp)
	add $fp, $sp, 32
	sw $s0, 0($fp)
	sw $s1, 4($fp)
	
	#Save the parameters
	move $s0, $a0
	move $s1, $a1
	
	#Call SBRK
	la $a0, 12
	li $v0, 9
	syscall
	move $s2, $v0
	#Check if there is enough memory
	beqz $s2, OutOfMemory
	
	sw $s0, 0($s2)
	sw $s1, 4($s2)
	move $v0, $s2
	
	#Free Pile
	lw $s0, 0($fp)
	lw $s1, 4($fp)
	lw $ra 28($sp)
	lw $fp, 24($sp)
	addu $sp, $sp, 32
	
	jr $ra
#endCreate
#-------------------------------------------------#

#void push(node_t *top, int val){
	#node_t *new_node = *top	//We create a auxNode
	
	#*new_node->val = val
	#*new_node->next = *top->next
	#*top = *new_node
#}
## $s0 => top
## $s1 => val
Push:
	# Create pile
	subu $sp, $sp, 32
	sw $ra, 28($sp)
	sw $fp, 24($sp)
	addu $fp, $sp, 32
	sw $s0, 0($fp)
	sw $s1, 4($fp)
	
	move $s0, $a0
	move $s1, $a1
	
	# Call create
	move $a0, $s0
	move $a1, $s1
	jal Create
	move $s2, $v0
	
	# Save the parameters
	sw $s0, 0($s2)
	sw $s1, 4($s2)
	move $v0, $s2
	
	#Free Pile
	lw $s0, 0($fp)
	lw $s1, 4($fp)
	lw $ra, 28($sp)
	lw $fp, 0($sp)		
	addiu $sp, $sp, 32
	
	jr $ra
#endPush
#-------------------------------------------------#

#int Pop(node_t *top) {
    #node_t *aux = *top;
    #if (aux != 0) {
        #*top = aux->next;
    #}
    #return temp;
#}
## s0 => top
## s1 => aux
Pop:
	#Create pile
	subu $sp, $sp, 32
	sw $ra, 28($sp)
	sw $fp, 24($sp)
	addu $fp, $sp, 32
	sw $s0, 0($fp)
	
	#Save parameters
	move $s0, $a0
	move $s1, $a0	# aux = top
	
	beqz $s1, finishPop
		lw $s0, 0($s1)	#*top = aux->next
		move $v0, $s0
		
	finishPop:
		lw $s0, 0($fp)
		lw $fp, 24($sp)
		lw $ra, 28($sp)
		addu $sp, $sp, 32
		jr $ra	
#endPop
#-------------------------------------------------#

#void print(node_t *top){
	#if top->next =! null {
		#print(top->next);
	#}
	#printf(“%d\n”, top->val);
	#return;
#}

#s0 = top
#$a0 = top->next
Print:
	#Create pile
	subu $sp, $sp, 32
	sw $ra, 28($sp)
	sw $fp, 24($sp)
	addu $fp, $sp, 32
	sw $s0, 0($fp)
	
	move $s0, $a0
	lw $a0, 0($s0)
	beqz $a0, endLoop
		move $a0, $a0
		jal Print
	
	endLoop:
		#Number
		li $v0, 1
		lw $a0, 4($s0)
		syscall
		#Guion
		la $a0, strGuion
		li $v0, 4
		syscall	
	
	#Free Pile
	lw $s0, 0($fp)
	lw $ra, 28($sp)
	lw $fp, 24($sp)
	addu $sp, $sp, 32
	#Go back
	jr $ra	
#endPrint

OutOfMemory:
	la $a0, strOutOfMemory
	li $v0, 4
	syscall

finishProgram:
	li $v0, 10
	syscall
