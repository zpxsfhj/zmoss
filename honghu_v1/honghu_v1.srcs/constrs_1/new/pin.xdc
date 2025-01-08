set_property PACKAGE_PIN D7  [get_ports o_pcie_txp[0]]
set_property PACKAGE_PIN B6  [get_ports o_pcie_txp[1]]
set_property PACKAGE_PIN D9  [get_ports i_pcie_rxp[0]]
set_property PACKAGE_PIN B10 [get_ports i_pcie_rxp[1]]

set_property PACKAGE_PIN F10 [get_ports i_pcie_refclk_p]

set_property PACKAGE_PIN L16 [get_ports i_pcie_reset_n ]

set_property IOSTANDARD LVCMOS33 [get_ports i_pcie_reset_n ]

set_property PACKAGE_PIN L13     [get_ports o_led[0] ]
set_property IOSTANDARD LVCMOS33 [get_ports o_led[0] ]
set_property PACKAGE_PIN M13     [get_ports o_led[1] ]
set_property IOSTANDARD LVCMOS33 [get_ports o_led[1] ]
set_property PACKAGE_PIN K14     [get_ports o_led[2] ]
set_property IOSTANDARD LVCMOS33 [get_ports o_led[2] ]
set_property PACKAGE_PIN K13     [get_ports o_led[3] ]
set_property IOSTANDARD LVCMOS33 [get_ports o_led[3] ]