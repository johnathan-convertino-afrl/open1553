EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Connector_Generic:Conn_02x06_Odd_Even J1
U 1 1 60C24DC1
P 3125 3650
F 0 "J1" H 3175 3100 50  0000 C CNN
F 1 "Conn_02x06_Top_Bottom" H 3175 3200 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_2x06_P2.54mm_Horizontal" H 3125 3650 50  0001 C CNN
F 3 "~" H 3125 3650 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Amphenol-FCI/10129382-912001BLF" H 3125 3650 50  0001 C CNN "Vendor"
	1    3125 3650
	-1   0    0    1   
$EndComp
$Comp
L power:GNDD #PWR02
U 1 1 60D056C0
P 3325 3750
F 0 "#PWR02" H 3325 3500 50  0001 C CNN
F 1 "GNDD" H 3275 3600 50  0000 C CNN
F 2 "" H 3325 3750 50  0001 C CNN
F 3 "" H 3325 3750 50  0001 C CNN
	1    3325 3750
	0    -1   -1   0   
$EndComp
$Comp
L power:GNDD #PWR01
U 1 1 60D05EA1
P 2825 3750
F 0 "#PWR01" H 2825 3500 50  0001 C CNN
F 1 "GNDD" H 2775 3600 50  0000 C CNN
F 2 "" H 2825 3750 50  0001 C CNN
F 3 "" H 2825 3750 50  0001 C CNN
	1    2825 3750
	0    1    1    0   
$EndComp
Wire Wire Line
	3325 3850 3325 4000
Wire Wire Line
	3325 4000 2825 4000
Wire Wire Line
	2825 4000 2825 3850
$Comp
L TBA_1-0311:TBA_1-0311 PS1
U 1 1 60CFB813
P 3375 4450
F 0 "PS1" V 3913 4022 50  0000 R CNN
F 1 "TBA_1-0311" V 3822 4022 50  0000 R CNN
F 2 "traco:TBA10311" H 4425 4550 50  0001 L CNN
F 3 "https://componentsearchengine.com/Datasheets/1/TBA 1-0511.pdf" H 4425 4450 50  0001 L CNN
F 4 "TRACO POWER - TBA 1-0311 - Isolated Board Mount DC/DC Converter, ITE, 1 Output, 1 W, 5 V, 200 mA" H 4425 4350 50  0001 L CNN "Description"
F 5 "10.5" H 4425 4250 50  0001 L CNN "Height"
F 6 "Traco Power" H 4425 4150 50  0001 L CNN "Manufacturer_Name"
F 7 "TBA 1-0311" H 4425 4050 50  0001 L CNN "Manufacturer_Part_Number"
F 8 "495-TBA1-0311" H 4425 3950 50  0001 L CNN "Mouser Part Number"
F 9 "https://www.mouser.co.uk/ProductDetail/TRACO-Power/TBA-1-0311?qs=byeeYqUIh0OdVWzHzjZFAA%3D%3D" H 4425 3850 50  0001 L CNN "Mouser Price/Stock"
F 10 "" H 4425 3750 50  0001 L CNN "Arrow Part Number"
F 11 "" H 4425 3650 50  0001 L CNN "Arrow Price/Stock"
F 12 "https://www.mouser.com/ProductDetail/TRACO-Power/TBA-1-0311" V 3375 4450 50  0001 C CNN "Vendor"
	1    3375 4450
	-1   0    0    -1  
$EndComp
$Comp
L power:GNDD #PWR03
U 1 1 60CFD8BD
P 3525 4450
F 0 "#PWR03" H 3525 4200 50  0001 C CNN
F 1 "GNDD" H 3525 4300 50  0000 C CNN
F 2 "" H 3525 4450 50  0001 C CNN
F 3 "" H 3525 4450 50  0001 C CNN
	1    3525 4450
	0    -1   1    0   
$EndComp
Wire Wire Line
	3375 4450 3450 4450
Wire Wire Line
	3375 4650 3450 4650
Wire Wire Line
	3450 4650 3450 4450
Connection ~ 3450 4450
Wire Wire Line
	3450 4450 3525 4450
$Comp
L Device:CP C1
U 1 1 60D04146
P 3450 4300
F 0 "C1" H 3332 4346 50  0000 R CNN
F 1 "22uF" H 3325 4425 50  0000 R CNN
F 2 "Capacitor_THT:CP_Radial_D5.0mm_P2.50mm" H 3488 4150 50  0001 C CNN
F 3 "~" H 3450 4300 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/647-UPW1A220MDD" H 3450 4300 50  0001 C CNN "Vendor"
	1    3450 4300
	-1   0    0    -1  
$EndComp
Wire Wire Line
	5225 4575 5500 4575
Wire Wire Line
	5225 5075 5225 4575
Wire Wire Line
	5200 5075 5225 5075
$Comp
L TB001-500-02BE:TB001-500-02BE IC2
U 1 1 60CC3999
P 8300 3200
F 0 "IC2" H 8592 2835 50  0000 C CNN
F 1 "TB001-500-02BE" H 8592 2926 50  0000 C CNN
F 2 "cui:TB00150002BE" H 8950 3300 50  0001 L CNN
F 3 "https://br.mouser.com/datasheet/2/670/tb001-500-1550615.pdf" H 8950 3200 50  0001 L CNN
F 4 "Fixed Terminal Blocks screw type, 5.00, horizontal, 2 poles, CUI Blue, slotted screw, PCB mount" H 8950 3100 50  0001 L CNN "Description"
F 5 "12.9" H 8950 3000 50  0001 L CNN "Height"
F 6 "CUI Inc." H 8950 2900 50  0001 L CNN "Manufacturer_Name"
F 7 "TB001-500-02BE" H 8950 2800 50  0001 L CNN "Manufacturer_Part_Number"
F 8 "490-TB001-500-02BE" H 8950 2700 50  0001 L CNN "Mouser Part Number"
F 9 "https://www.mouser.co.uk/ProductDetail/CUI-Devices/TB001-500-02BE?qs=vLWxofP3U2zBBnHgU5u3DA%3D%3D" H 8950 2600 50  0001 L CNN "Mouser Price/Stock"
F 10 "TB001-500-02BE" H 8950 2500 50  0001 L CNN "Arrow Part Number"
F 11 "https://www.arrow.com/en/products/tb001-500-02be/cui-devices" H 8950 2400 50  0001 L CNN "Arrow Price/Stock"
F 12 "https://www.mouser.com/ProductDetail/CUI-Devices/TB001-500-02BE" H 8300 3200 50  0001 C CNN "Vendor"
	1    8300 3200
	1    0    0    1   
$EndComp
$Comp
L TB001-500-02BE:TB001-500-02BE IC1
U 1 1 60CC3436
P 8300 4925
F 0 "IC1" H 8592 4560 50  0000 C CNN
F 1 "TB001-500-02BE" H 8592 4651 50  0000 C CNN
F 2 "cui:TB00150002BE" H 8950 5025 50  0001 L CNN
F 3 "https://br.mouser.com/datasheet/2/670/tb001-500-1550615.pdf" H 8950 4925 50  0001 L CNN
F 4 "Fixed Terminal Blocks screw type, 5.00, horizontal, 2 poles, CUI Blue, slotted screw, PCB mount" H 8950 4825 50  0001 L CNN "Description"
F 5 "12.9" H 8950 4725 50  0001 L CNN "Height"
F 6 "CUI Inc." H 8950 4625 50  0001 L CNN "Manufacturer_Name"
F 7 "TB001-500-02BE" H 8950 4525 50  0001 L CNN "Manufacturer_Part_Number"
F 8 "490-TB001-500-02BE" H 8950 4425 50  0001 L CNN "Mouser Part Number"
F 9 "https://www.mouser.co.uk/ProductDetail/CUI-Devices/TB001-500-02BE?qs=vLWxofP3U2zBBnHgU5u3DA%3D%3D" H 8950 4325 50  0001 L CNN "Mouser Price/Stock"
F 10 "TB001-500-02BE" H 8950 4225 50  0001 L CNN "Arrow Part Number"
F 11 "https://www.arrow.com/en/products/tb001-500-02be/cui-devices" H 8950 4125 50  0001 L CNN "Arrow Price/Stock"
F 12 "https://www.mouser.com/ProductDetail/CUI-Devices/TB001-500-02BE" H 8300 4925 50  0001 C CNN "Vendor"
	1    8300 4925
	1    0    0    1   
$EndComp
Wire Wire Line
	6100 4675 6225 4675
Wire Wire Line
	6100 5075 6225 5075
Wire Wire Line
	5500 5175 5200 5175
Wire Wire Line
	7975 3050 7900 3050
Wire Wire Line
	7975 3250 7900 3250
Wire Wire Line
	6925 3050 6925 2950
Wire Wire Line
	6925 4975 6925 5075
Wire Wire Line
	6925 4675 6925 4775
$Comp
L Murata_Pulse_Transformers:78604-9JC P2
U 1 1 60C7B5E2
P 7550 3150
F 0 "P2" H 7550 3475 50  0000 C CNN
F 1 "78604-9JC" H 7550 3400 50  0000 C CNN
F 2 "murata_pulse_transformers:78604-9JC" H 7550 3150 50  0001 C CNN
F 3 "" H 7550 3150 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Murata-Power-Solutions/78604-9JC" H 7550 3150 50  0001 C CNN "Vendor"
	1    7550 3150
	-1   0    0    -1  
$EndComp
Wire Wire Line
	7975 4775 7900 4775
Wire Wire Line
	7975 4825 7975 4775
Wire Wire Line
	7975 4975 7975 4925
Wire Wire Line
	7900 4975 7975 4975
Wire Wire Line
	7975 3200 7975 3250
Wire Wire Line
	7975 3050 7975 3100
$Comp
L power:GNDD #PWR010
U 1 1 60D3A071
P 5800 4025
F 0 "#PWR010" H 5800 3775 50  0001 C CNN
F 1 "GNDD" H 5800 3875 50  0000 C CNN
F 2 "" H 5800 4025 50  0001 C CNN
F 3 "" H 5800 4025 50  0001 C CNN
	1    5800 4025
	0    1    1    0   
$EndComp
$Comp
L Device:C C7
U 1 1 60D395EB
P 5800 4200
F 0 "C7" H 5915 4246 50  0000 L CNN
F 1 "100NF" H 5915 4155 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.7mm_W2.5mm_P5.00mm" H 5838 4050 50  0001 C CNN
F 3 "~" H 5800 4200 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/TDK/FK26C0G1H104J" H 5800 4200 50  0001 C CNN "Vendor"
	1    5800 4200
	1    0    0    -1  
$EndComp
$Comp
L Device:C C8
U 1 1 60D39087
P 5800 3850
F 0 "C8" H 5915 3896 50  0000 L CNN
F 1 "100NF" H 5915 3805 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.7mm_W2.5mm_P5.00mm" H 5838 3700 50  0001 C CNN
F 3 "~" H 5800 3850 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/TDK/FK26C0G1H104J" H 5800 3850 50  0001 C CNN "Vendor"
	1    5800 3850
	1    0    0    -1  
$EndComp
Wire Wire Line
	5500 3350 5325 3350
Wire Wire Line
	5500 4875 5500 4975
Connection ~ 5500 4875
$Comp
L power:GNDD #PWR04
U 1 1 60D00301
P 5500 4875
F 0 "#PWR04" H 5500 4625 50  0001 C CNN
F 1 "GNDD" H 5500 4725 50  0000 C CNN
F 2 "" H 5500 4875 50  0001 C CNN
F 3 "" H 5500 4875 50  0001 C CNN
	1    5500 4875
	0    1    1    0   
$EndComp
Wire Wire Line
	5500 4775 5500 4875
$Comp
L power:GNDD #PWR07
U 1 1 60CC9492
P 6925 4375
F 0 "#PWR07" H 6925 4125 50  0001 C CNN
F 1 "GNDD" H 6925 4225 50  0000 C CNN
F 2 "" H 6925 4375 50  0001 C CNN
F 3 "" H 6925 4375 50  0001 C CNN
	1    6925 4375
	-1   0    0    1   
$EndComp
$Comp
L Device:R R8
U 1 1 60CBA98E
P 8125 3200
F 0 "R8" V 8240 3200 50  0000 C CNN
F 1 "49R9" V 8331 3200 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 8055 3200 50  0001 C CNN
F 3 "~" H 8125 3200 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/TE-Connectivity-Holsworthy/YR1B49R9CC" V 8125 3200 50  0001 C CNN "Vendor"
	1    8125 3200
	0    1    1    0   
$EndComp
$Comp
L Device:R R7
U 1 1 60CBA57F
P 8125 3100
F 0 "R7" V 7918 3100 50  0000 C CNN
F 1 "49R9" V 8009 3100 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 8055 3100 50  0001 C CNN
F 3 "~" H 8125 3100 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/TE-Connectivity-Holsworthy/YR1B49R9CC" V 8125 3100 50  0001 C CNN "Vendor"
	1    8125 3100
	0    1    1    0   
$EndComp
$Comp
L Device:R R6
U 1 1 60CBA1CB
P 8125 4925
F 0 "R6" V 8240 4925 50  0000 C CNN
F 1 "49R9" V 8331 4925 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 8055 4925 50  0001 C CNN
F 3 "~" H 8125 4925 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/TE-Connectivity-Holsworthy/YR1B49R9CC?qs=%2Fha2pyFaduj9DVYKP1mQ5I6cbHeSbqcRTxxAPrgoG9nIERwP%252BGOgJQ%3D%3D" V 8125 4925 50  0001 C CNN "Vendor"
	1    8125 4925
	0    -1   1    0   
$EndComp
$Comp
L Device:R R5
U 1 1 60CB9C9F
P 8125 4825
F 0 "R5" V 7918 4825 50  0000 C CNN
F 1 "49R9" V 8009 4825 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 8055 4825 50  0001 C CNN
F 3 "~" H 8125 4825 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/TE-Connectivity-Holsworthy/YR1B49R9CC?qs=%2Fha2pyFaduj9DVYKP1mQ5I6cbHeSbqcRTxxAPrgoG9nIERwP%252BGOgJQ%3D%3D" V 8125 4825 50  0001 C CNN "Vendor"
	1    8125 4825
	0    1    1    0   
$EndComp
Wire Wire Line
	6250 2850 6100 2850
Wire Wire Line
	6250 2950 6250 2850
Wire Wire Line
	6250 3450 6100 3450
Wire Wire Line
	6250 3350 6250 3450
$Comp
L Device:C C4
U 1 1 60C656CB
P 6925 5225
F 0 "C4" H 6700 5225 50  0000 L CNN
F 1 "10pF" H 7050 5225 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.7mm_W2.5mm_P5.00mm" H 6963 5075 50  0001 C CNN
F 3 "~" H 6925 5225 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/TDK/FK18C0G1H100D" H 6925 5225 50  0001 C CNN "Vendor"
	1    6925 5225
	1    0    0    -1  
$EndComp
$Comp
L Device:C C3
U 1 1 60C651BD
P 6925 4525
F 0 "C3" H 6725 4525 50  0000 L CNN
F 1 "10pF" H 7025 4525 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.7mm_W2.5mm_P5.00mm" H 6963 4375 50  0001 C CNN
F 3 "~" H 6925 4525 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/TDK/FK18C0G1H100D" H 6925 4525 50  0001 C CNN "Vendor"
	1    6925 4525
	1    0    0    -1  
$EndComp
$Comp
L Device:R R3
U 1 1 60C63E75
P 6725 2950
F 0 "R3" V 6518 2950 50  0000 C CNN
F 1 "100" V 6609 2950 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 6655 2950 50  0001 C CNN
F 3 "~" H 6725 2950 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/TE-Connectivity-Holsworthy/YR1B100RCC" V 6725 2950 50  0001 C CNN "Vendor"
	1    6725 2950
	0    1    1    0   
$EndComp
$Comp
L Device:R R2
U 1 1 60C63B3C
P 5050 5075
F 0 "R2" V 4875 5075 50  0000 C CNN
F 1 "100" V 4950 5075 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 4980 5075 50  0001 C CNN
F 3 "~" H 5050 5075 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/TE-Connectivity-Holsworthy/YR1B100RCC" V 5050 5075 50  0001 C CNN "Vendor"
	1    5050 5075
	0    1    1    0   
$EndComp
$Comp
L Device:R R1
U 1 1 60C63662
P 5050 5175
F 0 "R1" V 5225 5175 50  0000 C CNN
F 1 "100" V 5125 5175 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 4980 5175 50  0001 C CNN
F 3 "~" H 5050 5175 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/TE-Connectivity-Holsworthy/YR1B100RCC" V 5050 5175 50  0001 C CNN "Vendor"
	1    5050 5175
	0    1    1    0   
$EndComp
$Comp
L Isolator:VO2630 U3
U 1 1 60C25854
P 5800 3150
F 0 "U3" H 5575 2575 50  0000 C CNN
F 1 "VO2630" H 5575 2675 50  0000 C CNN
F 2 "Package_DIP:DIP-8_W7.62mm" H 5900 2430 50  0001 C CNN
F 3 "https://www.vishay.com/doc?84732" H 5400 3500 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Vishay-Semiconductors/VO2630" H 5800 3150 50  0001 C CNN "Vendor"
	1    5800 3150
	-1   0    0    1   
$EndComp
$Comp
L Isolator:VO2630 U2
U 1 1 60C251B0
P 5800 4875
F 0 "U2" H 6075 5275 50  0000 C CNN
F 1 "VO2630" H 5425 5275 50  0000 C CNN
F 2 "Package_DIP:DIP-8_W7.62mm" H 5900 4155 50  0001 C CNN
F 3 "https://www.vishay.com/doc?84732" H 5400 5225 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Vishay-Semiconductors/VO2630?qs=xCMk%252BIHWTZOuc1EdsOwr1g%3D%3D" H 5800 4875 50  0001 C CNN "Vendor"
	1    5800 4875
	1    0    0    -1  
$EndComp
$Comp
L power:GNDD #PWR0101
U 1 1 60D7C417
P 5800 5375
F 0 "#PWR0101" H 5800 5125 50  0001 C CNN
F 1 "GNDD" H 5800 5225 50  0000 C CNN
F 2 "" H 5800 5375 50  0001 C CNN
F 3 "" H 5800 5375 50  0001 C CNN
	1    5800 5375
	1    0    0    -1  
$EndComp
$Comp
L power:GNDD #PWR0102
U 1 1 60D7C98C
P 6925 5375
F 0 "#PWR0102" H 6925 5125 50  0001 C CNN
F 1 "GNDD" H 6925 5225 50  0000 C CNN
F 2 "" H 6925 5375 50  0001 C CNN
F 3 "" H 6925 5375 50  0001 C CNN
	1    6925 5375
	1    0    0    -1  
$EndComp
$Comp
L power:GNDD #PWR0103
U 1 1 60D7E7F5
P 5800 2650
F 0 "#PWR0103" H 5800 2400 50  0001 C CNN
F 1 "GNDD" H 5800 2500 50  0000 C CNN
F 2 "" H 5800 2650 50  0001 C CNN
F 3 "" H 5800 2650 50  0001 C CNN
	1    5800 2650
	-1   0    0    1   
$EndComp
Wire Wire Line
	3325 3650 4650 3650
Wire Wire Line
	4650 3650 4650 5175
Wire Wire Line
	4650 5175 4900 5175
Wire Wire Line
	4900 5075 4750 5075
Wire Wire Line
	4750 5075 4750 3550
Wire Wire Line
	4750 3550 3325 3550
Connection ~ 3325 4000
Wire Wire Line
	5800 4000 5800 4025
Connection ~ 5800 4025
Wire Wire Line
	5800 4025 5800 4050
Wire Wire Line
	5800 4375 5800 4350
Wire Wire Line
	4300 4350 4300 4750
Wire Wire Line
	3375 4750 4300 4750
Connection ~ 5800 4350
Wire Wire Line
	3325 4000 3450 4000
Wire Wire Line
	3450 4150 3450 4000
Connection ~ 3450 4000
Wire Wire Line
	3375 4550 3850 4550
Wire Wire Line
	3450 4000 3850 4000
$Comp
L Device:R R11
U 1 1 60CBBDD4
P 6225 4525
F 0 "R11" V 6050 4525 50  0000 C CNN
F 1 "100" V 6125 4525 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 6155 4525 50  0001 C CNN
F 3 "~" H 6225 4525 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/TE-Connectivity-Holsworthy/YR1B100RCC" V 6225 4525 50  0001 C CNN "Vendor"
	1    6225 4525
	-1   0    0    1   
$EndComp
$Comp
L Device:R R12
U 1 1 60CBC3DF
P 6225 5225
F 0 "R12" V 6050 5225 50  0000 C CNN
F 1 "100" V 6125 5225 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 6155 5225 50  0001 C CNN
F 3 "~" H 6225 5225 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/TE-Connectivity-Holsworthy/YR1B100RCC" V 6225 5225 50  0001 C CNN "Vendor"
	1    6225 5225
	-1   0    0    1   
$EndComp
$Comp
L Device:R R10
U 1 1 60CBC868
P 5325 3500
F 0 "R10" V 5118 3500 50  0000 C CNN
F 1 "332_2K2-DNP" V 5225 3650 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 5255 3500 50  0001 C CNN
F 3 "~" H 5325 3500 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/TE-Connectivity-Holsworthy/YR1B332RCC" V 5325 3500 50  0001 C CNN "Vendor"
	1    5325 3500
	-1   0    0    1   
$EndComp
Connection ~ 5325 3350
$Comp
L Device:R R9
U 1 1 60CBD27F
P 5325 2800
F 0 "R9" V 5118 2800 50  0000 C CNN
F 1 "332_2K2-DNP" V 5225 2675 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 5255 2800 50  0001 C CNN
F 3 "~" H 5325 2800 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/TE-Connectivity-Holsworthy/YR1B332RCC" V 5325 2800 50  0001 C CNN "Vendor"
	1    5325 2800
	-1   0    0    1   
$EndComp
Connection ~ 5325 2950
Wire Wire Line
	5325 2950 5500 2950
Wire Wire Line
	4300 5750 4300 4750
Connection ~ 4300 4750
Connection ~ 6225 5075
Wire Wire Line
	6225 5375 6225 5750
Wire Wire Line
	6225 5750 4300 5750
Connection ~ 6225 4675
Wire Wire Line
	6225 4375 6225 4350
Wire Wire Line
	6225 4350 5800 4350
$Comp
L Murata_Pulse_Transformers:78604-9JC P1
U 1 1 60C7C036
P 7550 4875
F 0 "P1" H 7537 5215 50  0000 C CNN
F 1 "78604-9JC" H 7537 5124 50  0000 C CNN
F 2 "murata_pulse_transformers:78604-9JC" H 7550 4875 50  0001 C CNN
F 3 "" H 7550 4875 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Murata-Power-Solutions/78604-9JC?qs=f4NXQ36d%252BdAJuzG35nIgNw%3D%3D" H 7550 4875 50  0001 C CNN "Vendor"
	1    7550 4875
	-1   0    0    -1  
$EndComp
Wire Wire Line
	2825 4000 2175 4000
Wire Wire Line
	2175 4000 2175 2650
Wire Wire Line
	2175 2650 3975 2650
Connection ~ 2825 4000
Wire Wire Line
	3850 4550 3850 4000
Wire Wire Line
	5325 3650 5325 4000
Wire Wire Line
	5325 4000 3850 4000
Connection ~ 3850 4000
Wire Wire Line
	6925 3050 7200 3050
Wire Wire Line
	7200 3250 6925 3250
Wire Wire Line
	6925 4775 7200 4775
Wire Wire Line
	7200 4975 6925 4975
Connection ~ 6925 4675
Wire Wire Line
	6225 4675 6925 4675
Connection ~ 6925 5075
Wire Wire Line
	6225 5075 6925 5075
Wire Wire Line
	6925 3250 6925 3350
$Comp
L Device:R R4
U 1 1 60C64394
P 6725 3350
F 0 "R4" V 6518 3350 50  0000 C CNN
F 1 "100" V 6609 3350 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 6655 3350 50  0001 C CNN
F 3 "~" H 6725 3350 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/TE-Connectivity-Holsworthy/YR1B100RCC" V 6725 3350 50  0001 C CNN "Vendor"
	1    6725 3350
	0    1    1    0   
$EndComp
Wire Wire Line
	6925 3350 6875 3350
Wire Wire Line
	6925 2950 6875 2950
$Comp
L Mechanical:MountingHole H1
U 1 1 60CCB657
P 6625 6150
F 0 "H1" H 6725 6196 50  0000 L CNN
F 1 "MountingHole" H 6725 6105 50  0000 L CNN
F 2 "MountingHole:MountingHole_2.2mm_M2_DIN965" H 6625 6150 50  0001 C CNN
F 3 "~" H 6625 6150 50  0001 C CNN
	1    6625 6150
	1    0    0    -1  
$EndComp
$Comp
L Mechanical:MountingHole H2
U 1 1 60CCBB54
P 7600 6125
F 0 "H2" H 7700 6171 50  0000 L CNN
F 1 "MountingHole" H 7700 6080 50  0000 L CNN
F 2 "MountingHole:MountingHole_2.2mm_M2_DIN965" H 7600 6125 50  0001 C CNN
F 3 "~" H 7600 6125 50  0001 C CNN
	1    7600 6125
	1    0    0    -1  
$EndComp
$Comp
L power:GNDA #PWR09
U 1 1 60CD5930
P 8625 4050
F 0 "#PWR09" H 8625 3800 50  0001 C CNN
F 1 "GNDA" H 8630 3877 50  0000 C CNN
F 2 "" H 8625 4050 50  0001 C CNN
F 3 "" H 8625 4050 50  0001 C CNN
	1    8625 4050
	1    0    0    -1  
$EndComp
$Comp
L power:GNDD #PWR05
U 1 1 60CDDB4C
P 8275 4075
F 0 "#PWR05" H 8275 3825 50  0001 C CNN
F 1 "GNDD" H 8279 3920 50  0000 C CNN
F 2 "" H 8275 4075 50  0001 C CNN
F 3 "" H 8275 4075 50  0001 C CNN
	1    8275 4075
	1    0    0    -1  
$EndComp
$Comp
L Device:C C2
U 1 1 60CDE55C
P 8425 3975
F 0 "C2" V 8175 3925 50  0000 L CNN
F 1 "1NF" V 8275 3925 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.7mm_W2.5mm_P5.00mm" H 8463 3825 50  0001 C CNN
F 3 "~" H 8425 3975 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/TDK/CK45-B3AD102KYNNA" V 8425 3975 50  0001 C CNN "Vendor"
	1    8425 3975
	0    1    1    0   
$EndComp
Wire Wire Line
	8625 4050 8625 3975
Wire Wire Line
	8625 3975 8575 3975
Wire Wire Line
	8275 3975 8275 4075
$Comp
L Connector_Generic:Conn_01x02 J2
U 1 1 60CE0D1D
P 8825 3875
F 0 "J2" H 8905 3867 50  0000 L CNN
F 1 "Conn_01x02" H 8905 3776 50  0000 L CNN
F 2 "Connector_Molex:Molex_KK-254_AE-6410-02A_1x02_P2.54mm_Vertical" H 8825 3875 50  0001 C CNN
F 3 "~" H 8825 3875 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Molex/22-29-2021" H 8825 3875 50  0001 C CNN "Vendor"
	1    8825 3875
	1    0    0    -1  
$EndComp
Connection ~ 8625 3975
Wire Wire Line
	8625 3975 8625 3875
$Comp
L Connector_Generic:Conn_01x02 J3
U 1 1 60DD4A71
P 9300 3200
F 0 "J3" H 9380 3192 50  0000 L CNN
F 1 "Conn_01x02" H 9380 3101 50  0000 L CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 9300 3200 50  0001 C CNN
F 3 "~" H 9300 3200 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Molex/22-29-2021" H 9300 3200 50  0001 C CNN "Vendor"
	1    9300 3200
	1    0    0    1   
$EndComp
Wire Wire Line
	8300 3100 8275 3100
Wire Wire Line
	8275 3200 8300 3200
Wire Wire Line
	8275 4825 8300 4825
Wire Wire Line
	8275 4925 8300 4925
Wire Wire Line
	9100 3100 8300 3100
Connection ~ 8300 3100
Wire Wire Line
	9100 3200 8300 3200
Connection ~ 8300 3200
Wire Wire Line
	6250 3350 6575 3350
Wire Wire Line
	6250 2950 6550 2950
Wire Wire Line
	6100 3250 6550 3250
Wire Wire Line
	6550 3250 6550 2950
Connection ~ 6550 2950
Wire Wire Line
	6550 2950 6575 2950
Wire Wire Line
	6100 3050 6250 3050
Wire Wire Line
	6250 3050 6250 3350
Connection ~ 6250 3350
$Comp
L logo:afrl L1
U 1 1 6108267E
P 6050 6125
F 0 "L1" H 6178 6171 50  0000 L CNN
F 1 "afrl" H 6178 6080 50  0000 L CNN
F 2 "logos:afrl" H 6050 6125 50  0001 C CNN
F 3 "" H 6050 6125 50  0001 C CNN
	1    6050 6125
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74HC14 U1
U 1 1 6109BA4C
P 5350 1225
F 0 "U1" H 5500 1000 50  0000 C CNN
F 1 "74HC14" H 5500 1100 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_LongPads" H 5350 1225 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74HC14" H 5350 1225 50  0001 C CNN
	1    5350 1225
	-1   0    0    1   
$EndComp
$Comp
L 74xx:74HC14 U1
U 2 1 610B023C
P 5325 1600
F 0 "U1" H 5475 1375 50  0000 C CNN
F 1 "74HC14" H 5475 1475 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_LongPads" H 5325 1600 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74HC14" H 5325 1600 50  0001 C CNN
	2    5325 1600
	-1   0    0    1   
$EndComp
Wire Wire Line
	4425 2950 4750 2950
Wire Wire Line
	4425 3350 5000 3350
Wire Wire Line
	3825 3450 3325 3450
Wire Wire Line
	3325 3350 3725 3350
Wire Wire Line
	3725 3350 3725 2950
Wire Wire Line
	3725 2950 3825 2950
Wire Wire Line
	3825 3350 3825 3450
$Comp
L 74xx:74HC14 U1
U 7 1 610D764E
P 3975 2150
F 0 "U1" H 4325 1925 50  0000 C CNN
F 1 "74HC14" H 4325 2025 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_LongPads" H 3975 2150 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74HC14" H 3975 2150 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Texas-Instruments/SN74HC14AN" H 3975 2150 50  0001 C CNN "Vendor"
	7    3975 2150
	-1   0    0    1   
$EndComp
Connection ~ 3975 2650
$Comp
L power:GNDD #PWR06
U 1 1 610E20D2
P 3975 1575
F 0 "#PWR06" H 3975 1325 50  0001 C CNN
F 1 "GNDD" H 3975 1425 50  0000 C CNN
F 2 "" H 3975 1575 50  0001 C CNN
F 3 "" H 3975 1575 50  0001 C CNN
	1    3975 1575
	-1   0    0    1   
$EndComp
$Comp
L Device:C C5
U 1 1 610E2A33
P 4300 2500
F 0 "C5" H 4415 2546 50  0000 L CNN
F 1 "100NF" H 4415 2455 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.7mm_W2.5mm_P5.00mm" H 4338 2350 50  0001 C CNN
F 3 "~" H 4300 2500 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/TDK/FK26C0G1H104J" H 4300 2500 50  0001 C CNN "Vendor"
	1    4300 2500
	1    0    0    -1  
$EndComp
Wire Wire Line
	3975 1650 3975 1575
Connection ~ 3975 1650
Connection ~ 4300 2650
Wire Wire Line
	4300 2650 5325 2650
Wire Wire Line
	3975 2650 4300 2650
Wire Wire Line
	4300 2350 4300 1650
Wire Wire Line
	3975 1650 4300 1650
$Comp
L 74xx:74HC14 U1
U 5 1 61103622
P 4125 3350
F 0 "U1" H 4275 3125 50  0000 C CNN
F 1 "74HC14" H 4275 3225 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_LongPads" H 4125 3350 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74HC14" H 4125 3350 50  0001 C CNN
	5    4125 3350
	-1   0    0    1   
$EndComp
$Comp
L 74xx:74HC14 U1
U 6 1 61106EEA
P 5350 2025
F 0 "U1" H 5500 1800 50  0000 C CNN
F 1 "74HC14" H 5500 1900 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_LongPads" H 5350 2025 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74HC14" H 5350 2025 50  0001 C CNN
	6    5350 2025
	-1   0    0    1   
$EndComp
$Comp
L 74xx:74HC14 U1
U 4 1 6110A8C5
P 4125 2950
F 0 "U1" H 4275 2725 50  0000 C CNN
F 1 "74HC14" H 4275 2825 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_LongPads" H 4125 2950 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74HC14" H 4125 2950 50  0001 C CNN
	4    4125 2950
	-1   0    0    1   
$EndComp
$Comp
L 74xx:74HC14 U1
U 3 1 6110E653
P 5350 825
F 0 "U1" H 5500 600 50  0000 C CNN
F 1 "74HC14" H 5500 700 50  0000 C CNN
F 2 "Package_DIP:DIP-14_W7.62mm_LongPads" H 5350 825 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74HC14" H 5350 825 50  0001 C CNN
	3    5350 825 
	-1   0    0    1   
$EndComp
$Comp
L power:GNDD #PWR0105
U 1 1 6111725A
P 5625 1600
F 0 "#PWR0105" H 5625 1350 50  0001 C CNN
F 1 "GNDD" H 5600 1450 50  0000 C CNN
F 2 "" H 5625 1600 50  0001 C CNN
F 3 "" H 5625 1600 50  0001 C CNN
	1    5625 1600
	0    -1   -1   0   
$EndComp
$Comp
L power:GNDD #PWR0106
U 1 1 6111F143
P 5650 1225
F 0 "#PWR0106" H 5650 975 50  0001 C CNN
F 1 "GNDD" H 5650 1075 50  0000 C CNN
F 2 "" H 5650 1225 50  0001 C CNN
F 3 "" H 5650 1225 50  0001 C CNN
	1    5650 1225
	0    -1   -1   0   
$EndComp
$Comp
L power:GNDD #PWR0107
U 1 1 61124E1C
P 5650 825
F 0 "#PWR0107" H 5650 575 50  0001 C CNN
F 1 "GNDD" H 5650 675 50  0000 C CNN
F 2 "" H 5650 825 50  0001 C CNN
F 3 "" H 5650 825 50  0001 C CNN
	1    5650 825 
	0    -1   -1   0   
$EndComp
Wire Wire Line
	5325 2650 5325 2375
Wire Wire Line
	5325 2375 5650 2375
Wire Wire Line
	5650 2375 5650 2025
Connection ~ 5325 2650
$Comp
L Device:C C9
U 1 1 610CA7A8
P 5000 3500
F 0 "C9" H 4800 3500 50  0000 L CNN
F 1 "22pF_DNP" V 5150 3225 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.7mm_W2.5mm_P5.00mm" H 5038 3350 50  0001 C CNN
F 3 "~" H 5000 3500 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/TDK/FK18C0G1H220J" H 5000 3500 50  0001 C CNN "Vendor"
	1    5000 3500
	1    0    0    -1  
$EndComp
Connection ~ 5000 3350
Wire Wire Line
	5000 3350 5325 3350
$Comp
L Device:C C6
U 1 1 610CB109
P 4750 3100
F 0 "C6" H 4625 3000 50  0000 L CNN
F 1 "22pF_DNP" V 4875 2875 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.7mm_W2.5mm_P5.00mm" H 4788 2950 50  0001 C CNN
F 3 "~" H 4750 3100 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/TDK/FK18C0G1H220J" H 4750 3100 50  0001 C CNN "Vendor"
	1    4750 3100
	1    0    0    -1  
$EndComp
Connection ~ 4750 2950
Wire Wire Line
	4750 2950 5325 2950
$Comp
L power:GNDD #PWR08
U 1 1 610CC809
P 4750 3250
F 0 "#PWR08" H 4750 3000 50  0001 C CNN
F 1 "GNDD" H 4750 3100 50  0000 C CNN
F 2 "" H 4750 3250 50  0001 C CNN
F 3 "" H 4750 3250 50  0001 C CNN
	1    4750 3250
	1    0    0    -1  
$EndComp
$Comp
L power:GNDD #PWR011
U 1 1 610CD1AE
P 5000 3650
F 0 "#PWR011" H 5000 3400 50  0001 C CNN
F 1 "GNDD" H 5000 3500 50  0000 C CNN
F 2 "" H 5000 3650 50  0001 C CNN
F 3 "" H 5000 3650 50  0001 C CNN
	1    5000 3650
	1    0    0    -1  
$EndComp
Wire Wire Line
	5800 3650 5800 3675
Wire Wire Line
	4300 4350 5525 4350
Wire Wire Line
	5800 3675 5525 3675
Wire Wire Line
	5525 3675 5525 4350
Connection ~ 5800 3675
Wire Wire Line
	5800 3675 5800 3700
Connection ~ 5525 4350
Wire Wire Line
	5525 4350 5800 4350
$EndSCHEMATC
