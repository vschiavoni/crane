################################################################################
# Automatically-generated file. Do not edit!
################################################################################

PARROT_INCLUDE=-I $(XTERN_ROOT)/include -lpthread

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/proxy/proxy.c 

OBJS += \
./src/proxy/proxy.o 

C_DEPS += \
./src/proxy/proxy.d 


# Each subdirectory must supply rules for building sources it contributes
src/proxy/%.o: ../src/proxy/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C Compiler'
	#gcc-4.8 -std=gnu11 -DDEBUG=$(DEBUGOPT) -I"$(ROOT_DIR)/../.local/include" $(PARROT_INCLUDE) -O0 -g3 -Wall -pg -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	#gcc-4.8 -std=gnu11 -DDEBUG=$(DEBUGOPT) -I"$(ROOT_DIR)/../.local/include" $(PARROT_INCLUDE) -O0 -g3 -Wall $(GPROF) -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	gcc -std=gnu11 -DDEBUG=$(DEBUGOPT) -I"$(ROOT_DIR)/../.local/include" $(PARROT_INCLUDE) -O0 -g3 -Wall $(GPROF) -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


