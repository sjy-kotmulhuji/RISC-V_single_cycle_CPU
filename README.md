
# RISC-V Single Cycle CPU Design and Simulation

이 프로젝트는 **RV32I 명령어 셋**을 기반으로 하는 **RISC-V 구조의 Single Cycle CPU**를 **System Verilog**로 설계하고 시뮬레이션한 프로젝트입니다.

## 1. 프로젝트 개요
*   **목표**: RISC-V RV32I 명령어 셋의 Type별 설계 및 동작 검증.
*   **설계 방식**: 명령어 처리 5단계(IF, ID, EX, MEM, WB)를 한 클락(Single Cycle) 내에 완료하는 구조.
*   **개발 환경**: System Verilog, Vivado (Simulation 분석).
*   **교육 과정**: 대한상공회의소 서울기술교육센터 온디바이스AI 반도체 설계 1기.

## 2. 프로세서 아키텍처
### 전체 블록 다이어그램
CPU는 크게 네 개의 주요 모듈로 구성됩니다.
*   **Instruction Memory (ROM)**: 명령어를 저장하는 공간으로 Word Addressing을 사용합니다.
*   **Control Unit**: 명령어를 해독하여 Datapath에 동작 신호를 전달합니다.
*   **Data Memory (RAM)**: 데이터 저장 공간으로 Word Addressing을 사용합니다.
*   **Datapath**: 실제 연산이 수행되는 경로로 PC, Register File, ALU, Immediate Extender 등으로 구성됩니다.

### 주요 모듈 기능
*   **Register File**: 연산에 필요한 데이터를 읽고 결과를 저장하는 32개의 임시 저장 공간입니다.
*   **ALU (Arithmetic Logic Unit)**: 명령어에 따른 산술 연산 및 비교를 실행합니다.
*   **Immediate Extender**: 상숫값(Imm)을 32비트로 Sign Extension 합니다.

## 3. 지원 명령어 셋 (RV32I)
기본 정수 명령어 세트인 RV32I의 6가지 타입 명령어를 모두 지원하도록 설계되었습니다.

| 타입 | 설명 | 주요 명령어 |
| :--- | :--- | :--- |
| **R-Type** | 레지스터 간 연산 | ADD, SUB, SLL, SLT, XOR, SRL, OR, AND |
| **I-Type** | 상수(Imm) 연산 및 Load | ADDI, SLTI, XORI, ORI, ANDI, LW, LB, LH 등 |
| **S-Type** | 메모리 저장 (Store) | SW, SB, SH |
| **B-Type** | 조건 분기 (Branch) | BEQ, BNE, BLT, BGE, BLTU, BGEU |
| **U-Type** | 상위 20비트 상수 처리 | LUI, AUIPC |
| **J-Type** | 무조건 점프 (Jump) | JAL, JALR |

## 4. 시뮬레이션 및 검증
각 명령어 타입별로 검증 시나리오를 작성하여 **Vivado Simulator**를 통해 동작을 확인했습니다.

*   **R-Type**: 산술/논리 연산 결과가 레지스터(rd)에 정확히 Write Back 되는지 확인.
*   **B-Type**: 비교 조건 만족 시 PC 값이 상숫값만큼 정상적으로 Jump 하는지 검증.
*   **Load/Store**: 메모리 주소 계산 및 Byte/Half-word 단위의 데이터 접근 동작 확인.
*   **실제 예제**: C언어로 작성된 '1부터 10까지 합산' 코드를 어셈블리로 변환하여 CPU에서 최종 결과값(55)이 산출되는 것을 확인했습니다.

## 5. 트러블슈팅 (Trouble Shooting)
### S-Type 설계 시 메모리 접근 문제
*   **문제**: 초기 설계 시 `SB`(Byte), `SH`(Half-word) 명령어 수행 중 메모리의 특정 비트에만 접근하는 데 어려움이 있었습니다.
*   **해결**: `daddr`의 하위 2비트를 활용한 `byte_en` 신호를 생성하여, 메모리의 각 8비트 구역에 개별적으로 접근할 수 있도록 로직을 수정하여 해결했습니다.
*   
