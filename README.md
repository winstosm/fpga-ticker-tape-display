
# FPGA Ticker-Tape Display System  
Finite State Machine (FSM) + Pipeline Architecture in VHDL  

## Overview  
This project implements a synchronous FPGA-based ticker-tape display system using VHDL. The design integrates a finite state machine (FSM) with an 8-stage shift-register pipeline to create a scrolling display, while ensuring reliable user input through synchronization and debounce filtering.  

---

## Key Features  
- Finite State Machine (FSM) for system control  
- 8-stage shift-register pipeline for scrolling display  
- Two flip-flop synchronizer for metastability mitigation  
- Debounce filtering for push-button input reliability  
- Fully synchronous FPGA design  

---

## System Architecture  

1. **Control Unit (FSM)**  
   Manages state transitions and system behavior  

2. **Shift Register Pipeline**  
   Enables staged data movement for scrolling output  

3. **Input Conditioning Module**  
   Synchronizes and debounces push-button inputs  

---

## Technologies Used  
- VHDL  
- Quartus Prime  
- ModelSim  
- FPGA development board (DE2-115 / DE10-Lite)  

---

## File Structure  

- **src/** – VHDL source files  
- **testbench/** – Simulation and verification files  
- **simulations/** – Waveforms or results (optional)  
- **docs/** – Diagrams and design notes  

---

## Results & Validation  
- Verified correct scrolling behavior through simulation  
- Stable operation with asynchronous input signals  
- Reliable FSM transitions and pipeline operation  

---

## Engineering Significance  
This project demonstrates:
- FSM-based system control  
- Pipeline architecture design in hardware  
- Input synchronization and debounce handling  
- Reliable synchronous system design  

---

## Intellectual Property & Technical Perspective  
This project reflects structured system design and documentation practices relevant to:
- Patent drafting and technical disclosures  
- Analysis of digital system architectures  
- Evaluation of hardware innovation  

---

## Future Improvements  
- Expand to dynamic message input  
- Integrate memory for message storage  
- Optimize pipeline efficiency  

---

## Author  
Sabra Winston  
Electrical & Computer Engineering, Vanderbilt University  
Focus: FPGA Systems, Embedded Computing, and Technology & IP  
