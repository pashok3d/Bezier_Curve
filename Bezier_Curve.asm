####################################################################################
# [ARKO] PROJECT MIPS-32 "Quadratic Bezier curve" ######## Author: PAVEL TARASHKEVICH   ###################
####################################################################################
# The program asks for 6 x,y-point coordinates, reads and processes "image_in.bmp" file using block method
# and saves result to "inage_out.bmp"
# Below you can adjust such parametrs ans STEP and BLOCK
####################################################################################
# Calcualtion comment: Obviously, the smallest visual unit we operate on is pixel. Though calculation requres decimal values,
# we actually don't have to deal with them, for defining pixel's position, because Bx and By will be rounded anyway.
# So it is just a matter of transorming Quadratic Bezier curve formula into the one where we have one division as last operation.
####################################################################################

.eqv STEP 100 # >1 # defines density of the curve (default. 10 for small size images/ 100 for medium size images)
.eqv BLOCK 2048 # >0 # defines size of buffer used for block-reading (theoretically can be any positive integer, not necessary 2^n) 
.data
input_info: 	.asciiz "Enter 6 coordinates: P0x, P0y, P1x, P1y, P2x, P2y \n"
file_open_fail: 	.asciiz "Failed to open the file. \n"
file_read_fail: 	.asciiz "Failed to read file. \n"
fail:			.asciiz "Error occurred while running program. \n"
pic:			.asciiz "image_in.bmp"
pic_res: 		.asciiz "image_out.bmp"
header: 		.space 54 		# hardcoded header's size of 24bit bmp
.align 2
meta_keeper: 	.space 4 		# help buffer for processing values from header
.align 2	
buffer: 		.space BLOCK	# buffer for block-reading
.text
main:

#----------------INITIALIZATION-------------------------

	#------------------$S_REGISTERS------------------------
				# $s0 descriptor image_in
	li $s1, STEP   	# $s1 T
				# $s2 width
				# $s3 padding
				# $s4 blocks amount
	li $s5, BLOCK	# $s5 block size = buffer size 			
				# $s6 descriptor image_out
				# $s7 
	#----------------------------------------------------------------
	
	#------------------$T_REGISTERS---------------------------
			# $t0 - $t5 RESERVED for coordinates
			# $t6 - RESERVED for great_iterator
	#----------------------------------------------------------------

#----------------------------------------------------------------

#-------------------------INPUT_INFO------------------------
li $v0, 4
la $a0, input_info
syscall
#----------------------------------------------------------------

#-----------------GET_POINTS_VALUES---------------------
# Getting P0x, P0y, P1x, P1y, P2x, P2y values

	#-------------P0----------------
		#-------------P0:X--------------
 		li $v0, 5		
 		syscall
 		move $t0, $v0
 		#--------------------------------
 		
 		#-------------P0:Y--------------
 		li $v0, 5		
 		syscall
 		move $t1, $v0
 		#--------------------------------
	#--------------------------------
	
	#-------------P1----------------
		#-------------P1:X--------------
 		li $v0, 5		
 		syscall
 		move $t2, $v0
 		#--------------------------------
 		
 		#-------------P1:Y--------------
 		li $v0, 5		
 		syscall
 		move $t3, $v0
 		#--------------------------------
	#--------------------------------
	
	#-------------P2----------------
		#-------------P2:X--------------
 		li $v0, 5		
 		syscall
 		move $t4, $v0
 		#--------------------------------
 		
 		#-------------P2:Y--------------
 		li $v0, 5		
 		syscall
 		move $t5, $v0
 		#--------------------------------
	#--------------------------------
	
#----------------------------------------------------------------

#----------------OPEN_FILE_FOR_READING----------------
# Opening image_in.bmp for reading (META-MODE)
  li   $v0, 13       	# system call for open file
  la  $a0, pic    		# output file name
  li   $a1, 0  		# open for reading (flags are 0: read, 1: write)
  li   $a2, 0    		# mode is ignored
  syscall           		# open a file (file descriptor returned in $v0)
  blt $v0, $0, file_open_fail_path	# fail case
  move $s0, $v0      	# save the file descriptor 
#----------------------------------------------------------------

#----------------FILE_READING------------------------------
#  Reading image_in.bmp (META-MODE)
#  Reading image_in.bmp's header meta data
	#---------------FILE_READING:BM--------------------
	# Reading image_in.bmp's header meta data
	li    $v0,   14  			# system call for reading file
	move   $a0,  $s0  		# output file descriptor
	la   $a1, meta_keeper   	# input buffer name
	li    $a2,    2			# input length
	syscall 				# read from file 
	bne $v0, 2, file_read_fail_path	#fail case
	#----------------------------------------------------------
	
	#---------------FILE_READING:FILE_SIZE--------------------
	# Reading image.bmp's header
	li    $v0,   14  			# system call for reading file
	move   $a0,  $s0  		# output file descriptor
	la   $a1, meta_keeper  	# input buffer name
	li    $a2,    4			# input length
	syscall 				# read from file 
	bne $v0, 4, file_read_fail_path	#fail case
	
		#----------FILE_READING:FILE_SIZE:STORE-------
		la $t7, meta_keeper						#------------------$T_REGISTER_USAGE_DISCLAMER---
		lw $t6, 0($t7)		# store FILE_SIZE to $s1	#------------------$T_REGISTER_USAGE_DISCLAMER---
		#----------------------------------------------------------
		
	#----------------------------------------------------------
	
	
	#---------------FILE_READING:reserved,DataOffset,Size---
	li    $v0,   14  			# system call for reading file
	move   $a0,  $s0  		# output file descriptor
	la   $a1, meta_keeper   	# input buffer name
	li    $a2,    12			# input length
	syscall 				# read from file 
	bne $v0, 12, file_read_fail_path 	#fail case
	#----------------------------------------------------------	--------											
												
	
	#---------------FILE_READING:Width--------------------
	li    $v0,   14  			# system call for reading file
	move   $a0,  $s0  		# output file descriptor
	la   $a1, meta_keeper   	# input buffer name
	li    $a2,    4			# input length
	syscall 				# read from file 
	bne $v0, 4, file_read_fail_path	#fail case
	
		#----------FILE_READING:Width:STORE-------
		la $t7, meta_keeper	
		lw $s2, 0($t7)
		#----------------------------------------------------
		
	#----------------------------------------------------------
	
#----------------------------------------------------------------

#----------------CLOSE_FILE---------------------------------
# Close image_in.bmp
  li   $v0, 16  		# system call for close file
  move $a0, $s0      	# file descriptor to close 
  syscall            		# close file
#----------------------------------------------------------------

#------------------PROCESSING_META_DATA----------------------
	#---------------------PADDING---------------------------------
	li $t7, 4 		# width mod 4					#------------------$T_REGISTER_USAGE_DISCLAMER---
	divu $s2, $t7 	# reminder goes to HI
	mfhi $s3		# pop padding
	#-----------------------------------------------------------------

	
	#---------------------BLOCKS_AMOUNT----------------------
	# (sizeOfFile - 54)/buffer_size
	subiu $t6 ,$t6, 54
	divu $t6, $s5 	
	mflo $s4 
	mfhi $t6 # reminder							#------------------$T_REGISTER_USAGE_DISCLAMER---
	beq $t6, $0, noremainder # if reminder == 0 then skip "+1"
	addiu $s4, $s4 1
	noremainder: 
	#-----------------------------------------------------------------
	
#-----------------------------------------------------------------


#----------------OPEN_FILE_FOR_READING----------------
# Opening image_in.bmp for reading (META-MODE & PIXEL_TABLE)
  li   $v0, 13       	# system call for open file
  la  $a0, pic    		# output file name
  li   $a1, 0  		# open for reading (flags are 0: read, 1: write)
  li   $a2, 0    		# mode is ignored
  syscall           		# open a file (file descriptor returned in $v0)
  blt $v0, $0, file_open_fail_path	#fail case
  move $s0, $v0      	# save the file descriptor 
#----------------------------------------------------------------

#---------------FILE_READING-------------------------------
#  Reading image_in.bmp's data

	#--------------FILE_READING:HEADER---------------------
	#  Reading image_in.bmp's header
	li    $v0,   14  		# system call for reading file
	move   $a0,  $s0  	# output file descriptor
	la   $a1, header   	# input buffer name
	li    $a2,    54		# input length
	syscall 			# read from file 
	bne $v0, 54, file_read_fail_path	#fail case
	#----------------------------------------------------------------
	
#----------------------------------------------------------------


#----------------OPEN_FILE_FOR_WRITING----------------
# Opening image_out.bmp for writing
  li   $v0, 13       	# system call for open file
  la  $a0, pic_res    	# output file name
  li   $a1, 1  		# open for reading (flags are 0: read, 1: write)
  li   $a2, 0    		# mode is ignored
  syscall           		# open a file (file descriptor returned in $v0)
  blt $v0, $0, file_open_fail_path
  move $s6, $v0      	# save the file descriptor 
#----------------------------------------------------------------


#----------------FILE_WRITING------------------------------
 	# Writing to image_out.bmp
 	
 	#----------------FILE_WRITING:HEADER-------------------
 	# Writing header to image_out.bmp
 	li   $v0, 15       		# system call for write to file
 	move $a0, $s6     	# file descriptor 
 	la  $a1, header 		# address of buffer from which to write #FLAG
 	li   $a2, 54     		# hardcoded buffer length
 	syscall            		# write to file
 	#----------------------------------------------------------------
 	
#----------------------------------------------------------------


#---------------FILE_READING-------------------------------
#  Reading image_in.bmp's data


	#--------------FILE_READING:PIXEL_TABLE---------------
	#  Reading image_in.bmp's pixel table (Buffer method)
	
		#------------------FILE_READING:PIXEL_TABLE:GREAT_LOOP----------
		
		move $t6, $s4 # great_iterator = amount of blocks				#------------------$T_REGISTER_USAGE_DISCLAMER---
		
		great_loop:
		beq $t6, $0, end_great_loop # if iterator == 0 then 				#------------------$T_REGISTER_USAGE_DISCLAMER---
		
		#---------------FILE_READING:PIXEL_TABLE:GET_BLOCK--------------------
		#  Reading block of image_in.bmp's pixel table data
		
		li    $v0,   14  		# system call for reading file
		move   $a0,  $s0  	# output file descriptor
		la   $a1, buffer   		# input buffer name
		li    $a2,   BLOCK		# input length 					
		syscall 			# read from file 
		#----------------------------------------------------------------
		
			#-------------------DRAWING-------------------------------
			
				#--------------------CALCULATIONS-------------------------
				
					move $t7, $0
				
					#--------------------CALCULATIONS:LOOP------------------
					calc_loop:
					beq $t7, $s1, end_calc_loop 	# if calc_iterator == T 
					
					move $t8, $0	# reset register
					move $t9, $0	#	...	
					move $s7, $0	#	...
					
					#--------------By---------------
					mul $s7, $t5, $t7 	# By = P2y * i
					mul $s7, $s7, $t7 	# By = P2y * i^2
					subu $t8, $s1, $t7	# help = T-i
					mul $t8, $t7, $t8 	# help = i*help = i*(T-i)= T*i - i^2
					mul $t8, $t8, 2 		# help = help*2 = 2*(T*i - i^2)
					mul $t8, $t8, $t3 	# help = help*P1y = P1y * 2*(T*i - i^2)
					addu $s7, $s7, $t8 	# Bx = P1y * 2*(T*i - i^2) + P2y * i^2  	
					mul $t8, $s1, $s1 	#help = T^2 
					mul $t8, $t8, $t1	#help = help * Poy = T^2 * Poy
					addu $s7, $s7, $t8	#By = By + help	
					mul $t8, $t7, $t7 	#help = t^2 
					mul $t8, $t8, $t1	#help = help * Poy
					addu $s7, $s7, $t8	#By = By + help
					mul $t8, $t7, $s1	#help = T*i
					mul $t8, $t8, 2		#help = help*2
					mul $t8, $t8, $t1	#help = help * Poy
					subu $s7, $s7, $t8	#By = By - help	
					mul $t8, $s1, $s1 	#help = T^2
					divu $s7, $t8
					mflo $t9 			# t9 = By
					#----------------------------------
					
					#--------------Bx---------------
					mul $s7, $t4, $t7 	# Bx = P2x * i
					mul $s7, $s7, $t7 	# Bx = P2x * i^2
					subu $t8, $s1, $t7	# help = T-i
					mul $t8, $t7, $t8 	# help = i*help = i*(T-i)= T*i - i^2
					mul $t8, $t8, 2 		# help = help*2 = 2*(T*i - i^2)
					mul $t8, $t8, $t2 	# help = help*P1x = P1x * 2*(T*i - i^2)
					addu $s7, $s7, $t8 	# Bx = P1x * 2*(T*i - i^2) + P2x * i^2  			
					mul $t8, $s1, $s1 	# help = T^2 
					mul $t8, $t8, $t0	# help = help * Pox = T^2 * Pox
					addu $s7, $s7, $t8	# Bx = Bx + help	
					mul $t8, $t7, $t7 	# help = t^2 
					mul $t8, $t8, $t0	# help = help * Pox
					addu $s7, $s7, $t8	# Bx = Bx + help
					mul $t8, $t7, $s1	# help = T*i
					mul $t8, $t8, 2		# help = help*2
					mul $t8, $t8, $t0	# help = help * Pox
					subu $s7, $s7, $t8	# Bx = Bx - help	
					mul $t8, $s1, $s1 	# help = T^2
					divu $s7, $t8
					mflo $t8 			# t8 = Bx
					#----------------------------------
					
					#----------CONVERT_TO_N_PIXEL----------------------------------
					# Calculating pixel's index in the pixel table (Pixel's position otherwise)
					# PN = y* width + x + 1 
	
					mulu $s7, $t9, $s2
					addu $s7, $s7, $t8
					addiu $s7, $s7, 1

					#----------------------------------------------------------------
					
					#----------CONVERT_TO_N_BYTE----------------------------------
					# Calculating pixel's 3 bytes' indexes (Pixel 3 bytes' position otherwise) 
					# !FLAG (1*) Rarely, pixel can be devided between two blocks - resulting in incorrect coloring 
					# BPN = 3(N-1) + y(pad) + 1/2/3
					# BPN = 3($t5 -1) + $t7*$s3 
	
					addiu $s7, $s7, -1
					mulu $s7, $s7, 3
					
					mulu $t9, $t9, $s3
					addu $s7, $s7, $t9
					addiu $s7, $s7, 1 
	
					#----------------------------------------------------------------
					
					#------------------------BLOCK_TAILS-----------------------
					# Calculating block's ends as bytes' indexes
						#------------------------BLOCK_TAILS:LEFT----------------
						subu $t8, $s4, $t6 # t1 = n-1 # Block's number(1)				#------------------$T_REGISTER_USAGE_DISCLAMER---
						mulu $t8, $t8, $s5 
						addiu $t8, $t8, 1 # N(0) -> N(1) # left block's tale
						#----------------------------------------------------------------
					
						#------------------------BLOCK_TAILS:RIGHT----------------
						addu $t9, $t8, $s5 										#------------------$T_REGISTER_USAGE_DISCLAMER---
						addiu $t9, $t9, -1 # right block's tale
						#----------------------------------------------------------------

					#----------------------------------------------------------------
					
					#-------------CHECK_IF_IN_BLOCK-------------------------
					# Check if calculated bytes belong to the block (fit block's tails)
					
					bgt  $s7, $t9, out
					blt   $s7, $t8, out
			
					subu $s7, $s7, $t8
					move $t8, $a1
					addu $t8, $t8, $s7
					
					sb $0, 0($t8)	# (1*) check comment
					sb $0, 1($t8)
					sb $0, 2($t8)
				
					out:
					#----------------------------------------------------------------
					
					addiu $t7, $t7, 1			#incrementation
					j calc_loop
					end_calc_loop:
					#----------------------------------------------------------------
					
				#----------------------------------------------------------------
				
		
			#----------------------------------------------------------------
		
		#----------------FILE_WRITING------------------------------
 			# Writing to image_out.bmp
 		
 			#----------------FILE_WRITING:PIXEL_TABLE:WRITE_BLOCK-------------------
 			# Writing processed block of image_in.bmp's pixel table data to image_out.bmp
 			
 			li   $v0, 15       		# system call for write to file
 			move $a0, $s6     	# file descriptor 
 			la  $a1, buffer 		# address of buffer from which to write #FLAG
 			li   $a2, BLOCK   	# buffer length					
 			syscall            		# write to file
 			#----------------------------------------------------------------
 		
 		#----------------------------------------------------------------
 		
 
		subiu $t6, $t6, 1 # iterator decrementation
		j great_loop
		end_great_loop:
		
		#--------------------------------------------------------------------------------
		
	#----------------------------------------------------------------
	
#----------------------------------------------------------------


#----------------CLOSE_FILE---------------------------------
# Closing picture
  li   $v0, 16  		# system call for close file
  move $a0, $s0      	# file descriptor to close 
  syscall            		# close file
#----------------------------------------------------------------

#----------------CLOSE_FILE---------------------------------
# Closing text
  li   $v0, 16  		# system call for close file
  move $a0, $s6      	# file descriptor to close 
  syscall            		# close file
#----------------------------------------------------------------

#-----------------TERMINATING----------------------------
 exit:
 li $v0, 10 
 syscall
 #----------------------------------------------------------------
 
 #----------------FAIL_PATHS---------------------------------
 file_open_fail_path: 
 li $v0, 4
 la $a0, file_open_fail
 syscall
 j exit 
 
 file_read_fail_path:
 li $v0, 4
 la $a0, file_read_fail
 syscall
 j exit
 
 fail_path:
 li $v0, 4
 la $a0, fail
 syscall
 j exit
#----------------------------------------------------------------
