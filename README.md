# RISC-V Single Cycle CPU

> RV32I Instruction Set 기반 Single Cycle CPU 설계 (SystemVerilog)

---

## 📌 프로젝트 개요

- RV32I 명령어 셋을 기반으로 하는 RISC-V 구조의 Single Cycle CPU 설계
- RV32I 명령어 셋 Type 별 설계 및 Simulation 검증
- C언어 코드를 활용한 Adder 예제 Code & Simulation 분석

---

## 🛠️ 개발 환경

- Language: SystemVerilog
- Tool: Vivado (Simulation)

---

## 📐 아키텍처 개요

### RISC-V란?

2010년 UC Berkeley에서 개발한 무료 오픈소스 ISA(Instruction Set Architecture)로, RISC(Reduced Instruction Set Computer) 방식으로 설계되었습니다.

| 특징 | 내용 |
|------|------|
| 명령어 길이 | 32비트 고정 |
| 명령어 구조 | 명령어 하나 당 동작 하나 |
| 메모리 접근 | Load/Store를 통해서만 가능 |
| ISA | RV32I (Base Integer Instruction Set) |


### 명령어 처리 5단계
```
IF (Instruction Fetch) → ID (Instruction Decode) → EX (Execute) → MEM (Memory) → WB (Write Back)
```

### Single Cycle CPU란?
<img width="1940" height="537" alt="image" src="https://github.com/user-attachments/assets/efaacbb1-93e0-45e1-9096-d4a8bde32602" />

- 명령어 처리 과정을 1 클락 사이클 내에 모두 완료하는 구조
- 클락 주기는 처리 시간이 가장 긴 명령어에 맞춤
- 장점: 하드웨어 구조가 단순함
- 단점: 모든 명령어가 가장 오래 걸리는 명령어 속도에 맞추므로 클럭 효율이 좋지 않음



---

## 🧱 Block Diagram

### 전체 구조
<img width="2389" height="1575" alt="Image" src="https://github.com/user-attachments/assets/2827d29f-fffe-4f38-9c72-ebd2acf26bcc" />

| 모듈 | 설명 |
|------|------|
| Instruction Memory (ROM) | 명령어 저장 공간. Word Addressing 사용 |
| Control Unit | 명령어를 해독해 Datapath에 동작 신호 전달 |
| Data Memory (RAM) | 데이터 저장 공간. Word Addressing 사용 |
| Datapath | Control Unit 신호를 받아 명령 실행 및 결과 도출 |

### Datapath 구성 모듈

| 모듈 | 설명 |
|------|------|
| Register File | CPU 내부에서 연산에 필요한 데이터를 읽고, 연산 결과를 Write Back하는 임시 저장 공간 |
| Immediate Extender | Imm 값을 32bit로 Sign Extension |
| ALU | 명령에 따른 연산 및 비교 실행 |
| Write Back MUX | 명령에 따라 Register File에 Write Back할 데이터 선택 |
| Program Counter | 실행될 명령어의 주소 제어 |

---

## 📋 RV32I Instruction Set

RISC-V의 기본 정수 명령어 세트로, 레지스터 크기(XLEN)는 32비트이며 6가지 타입으로 구분됩니다.
<img width="3325" height="447" alt="Image" src="https://github.com/user-attachments/assets/c55d32d5-2d44-440b-b9c4-67b73b586880" />

### 명령어 필드 설명

| 필드 | 설명 |
|------|------|
| `opcode` | 명령어 Type 구분 |
| `funct3` | 해당 Type 명령 중 어떤 연산인지 구분 |
| `funct7` | funct3만으로 구분 불가한 경우 사용 (R-Type 전용) |
| `imm` | 즉시값 (상수) |
| `rs1`, `rs2` | 연산에 필요한 데이터의 레지스터 인덱스 |
| `rd` | 연산 결과를 저장할 레지스터 인덱스 |

### Control Unit Signal Truth Table

| Type | rf_we | alu_src | alu_control | branch | jal | jalr | rfwd_src | o_funct3 | dwe |
|------|:-----:|:-------:|:-----------:|:------:|:---:|:----:|:--------:|:--------:|:---:|
| R | 1 | 0 | {funct7[5], funct3} | 0 | 0 | 0 | 000 | 000 | 0 |
| B | 0 | 0 | {1'b0, funct3} | 1 | 0 | 0 | 000 | 000 | 0 |
| S | 0 | 1 | 0000 | 0 | 0 | 0 | 000 | funct3 | 1 |
| JALR | 1 | 1 | 0000 | 0 | 1 | 1 | 100 | 000 | 0 |
| I (Load) | 1 | 1 | 0000 | 0 | 0 | 0 | 001 | funct3 | 0 |
| I (연산) | 1 | 1 | {funct7[5], funct3} / {1'b0, funct3} | 0 | 0 | 0 | 000 | funct3 | 0 |
| U (LUI) | 1 | 1 | 0000 | 0 | 0 | 0 | 010 | 000 | 0 |
| U (AUIPC) | 1 | 1 | 0000 | 0 | 0 | 0 | 011 | 000 | 0 |
| J | 1 | 1 | 0000 | 0 | 1 | 0 | 100 | 000 | 0 |

---

## 🔍 Type별 상세 설명

### R-Type (Register Type)
레지스터 값 2개를 연산한 결과를 레지스터에 저장합니다.
#### R-Type Instruction Datapath
<img width="2381" height="1263" alt="Image" src="https://github.com/user-attachments/assets/fdf236fb-851a-46df-8cdc-c7e34e7ec506" />

**동작 순서**
1. Register File에서 rs1, rs2 값 Read
2. ALU에서 연산
3. 연산 결과 Register File rd에 Write Back

**명령어**: `ADD` `SUB` `SLL` `SLT` `SLTU` `XOR` `SRL` `SRA` `OR` `AND`

#### R-Type Instruction Simulation
<img width="1408" height="465" alt="Image" src="https://github.com/user-attachments/assets/9b99f578-3f9f-4580-8a55-607b955abbf1" />

---

### B-Type (Branch Type)
조건 만족 시 `PC += imm`, 불만족 시 `PC += 4`로 분기합니다.
#### B-Type Instruction Datapath
<img width="2332" height="1229" alt="Image" src="https://github.com/user-attachments/assets/613b2a37-6d47-46ea-93f3-05f104e1e658" />

**동작 순서**
1. Register File에서 rs1, rs2 값 Read
2. 비교 결과가 조건에 부합하면 btaken 신호 출력
3. btaken = 1이면 PC += imm

**명령어**: `BEQ` `BNE` `BLT` `BGE` `BLTU` `BGEU`

#### B-Type Instruction Simulation
<img width="1567" height="521" alt="Image" src="https://github.com/user-attachments/assets/f5dcee51-0040-458d-8bc6-d7804fac6966" />

---

### S-Type (Store Type)
레지스터에 저장된 값을 메모리에 저장합니다.
#### S-Type Instruction Datapath
<img width="2319" height="1219" alt="Image" src="https://github.com/user-attachments/assets/7be68def-079d-4db1-8dee-6e19cf0330ef" />

**동작 순서**
1. Register File에서 rs1, rs2 값 Read
2. 메모리 Write Address: rs1 + imm
3. 메모리 Write Data: rs2

**명령어**: `SW` `SH` `SB`

#### S-Type Instruction(SW) Simulation
<img width="763" height="502" alt="Image" src="https://github.com/user-attachments/assets/cdd6fcab-3510-4fc2-933a-ebe834d5bc2a" />

---

### I-Type (Load)
메모리에 저장된 값을 레지스터로 Load합니다.
#### IL-Type Instruction Datapath
<img width="2316" height="1220" alt="Image" src="https://github.com/user-attachments/assets/f13a9997-55ab-448a-8e9a-fabce7100bb3" />


**동작 순서**
1. 메모리의 rs1 + imm 번지 데이터 읽기
2. Write Back MUX를 통해 레지스터에 Load

**명령어**: `LB` `LH` `LW` `LBU` `LHU`

#### IL-Type Instruction Simulation
<img width="966" height="532" alt="Image" src="https://github.com/user-attachments/assets/ea68a94f-76b5-499b-8e48-445e60ce87fa" />

---

### I-Type (연산)
Imm 값을 이용해 연산한 결과를 레지스터에 저장합니다.
#### I-Type Instruction Datapath
<img width="2319" height="1220" alt="Image" src="https://github.com/user-attachments/assets/97b5de0b-5999-4899-a7fd-91bf26e80260" />

**동작 순서**
1. rs1, imm 값을 ALU에서 명령에 따라 연산
2. 레지스터에 Write Back

**명령어**: `ADDI` `SLTI` `SLTIU` `XORI` `ORI` `ANDI` `SLLI` `SRLI` `SRAI`

#### I-Type Instruction Simulation
<img width="1027" height="435" alt="Image" src="https://github.com/user-attachments/assets/517036d2-6962-454b-8270-7a1d978be8a5" />

---

### JALR (Jump And Link Register)
복귀할 주소를 rd에 저장(Link)하고 목적지로 Jump합니다.
#### JALR Instruction Datapath
<img width="2319" height="1214" alt="Image" src="https://github.com/user-attachments/assets/1a11c265-38b2-46fa-a037-2ece2a6dfa6e" />

**동작**
```
rd  = PC + 4   (복귀 주소 저장)
PC  = rs1 + imm (Jump)
```
#### JALR Instruction Simulation
<img width="927" height="412" alt="Image" src="https://github.com/user-attachments/assets/fe645158-187c-4428-8791-dfeeca6bea1d" />
---

### U-Type (Upper Immediate Type)
12비트보다 큰 Imm 값이 필요할 때 사용합니다.
#### U-Type Instruction Datapath
<img width="2319" height="1235" alt="Image" src="https://github.com/user-attachments/assets/35c27a2c-0318-4b21-9c84-392256f0d691" />

**동작**
```
LUI   : rd = {imm, 12'h000}
AUIPC : rd = PC + {imm, 12'h000}
```

**명령어**: `LUI` `AUIPC`

#### U-Type Instruction Simulation
<img width="1067" height="442" alt="Image" src="https://github.com/user-attachments/assets/74fcd4cc-415a-4c6b-9854-3f96bc9a439b" />

---

### J-Type (Jump Type)
돌아올 주소를 저장하고 PC를 Jump합니다. JALR과 달리 현재 PC 기준으로 Jump하므로 비교적 가까운 함수 호출에 사용됩니다.
#### J-Type Instruction Datapath
<img width="2323" height="1225" alt="Image" src="https://github.com/user-attachments/assets/39b3d0d1-49a1-40f0-8de9-865625d75fc3" />

**동작**
```
rd = PC + 4   (복귀 주소 저장)
PC += imm     (Jump)
```

**명령어**: `JAL`

#### J-Type Instruction Simulation
<img width="852" height="417" alt="Image" src="https://github.com/user-attachments/assets/4f72a19a-45b4-4f2d-a8a7-1c6b79a6df3b" />

---

## 💻 C & Assembly 활용 예제

### Adder 예제

1~10까지 합한 값을 구하는 프로그램을 C언어로 작성 후 RISC-V Assembly로 변환하여 검증하였습니다.

**코드 변환 과정**
```
C언어 작성 → RISC-V Assembly 변환 → Hex Dump 변환 → ROM에 저장
```

**주요 레지스터**

| 레지스터 | ABI 명칭 | 역할 |
|---------|---------|------|
| x1 | ra | Return Address (함수 종료 후 돌아갈 주소) |
| x2 | sp | Stack Pointer (현재 스택 top 위치) |
| x8 | s0 | Frame Pointer (현재 함수 스택의 기준점) |

---

## 🐛 Trouble Shooting

#### S-Type 명령어 로직 오류

**문제**: Word Addressing 기반 메모리에서 SB(1바이트), SH(2바이트) 단위로 특정 bit에만 데이터를 저장해야 하는데 로직 오류로 32bit 전체에 저장하게 됨.

**해결**: `daddr` 하위 2비트와 byte_en 신호를 이용해 Data Memory의 원하는 bit에 접근할 수 있도록 구현

