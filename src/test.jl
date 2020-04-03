Nr_Elevationbands = 2
test_input = HRU_Input([0.5, 0.5], 1, 0.0, Nr_Elevationbands, [2,2], 2, [10,10], 0, [10, 10], 0, 0)
test_storage = Storages(0, zeros(Nr_Elevationbands), zeros(Nr_Elevationbands), 0)
test_parameters = Parameters(1, 0.4, 0, 2, 0.8, 1, 0.5, 0.1, 0.1, 50, 0)

bare_outflow, bare_storage = hillslopeHRU(test_input, test_storage, test_parameters)
