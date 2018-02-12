//======================================================================
//
// tb_salsa20_core.v
// -----------------
// Testbench for the Salsa20 stream cipher core.
//
//
// Copyright (c) 2013, Secworks Sweden AB
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or
// without modification, are permitted provided that the following
// conditions are met:
//
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in
//    the documentation and/or other materials provided with the
//    distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//======================================================================

module tb_salsa20_core();

  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  parameter CLK_HALF_PERIOD = 2;

  parameter TC1  = 1;
  parameter TC2  = 2;
  parameter TC3  = 3;
  parameter TC4  = 4;
  parameter TC5  = 5;
  parameter TC6  = 6;
  parameter TC7  = 7;
  parameter TC8  = 8;
  parameter TC9  = 9;
  parameter TC10 = 10;

  parameter ONE   = 1;
  parameter TWO   = 2;
  parameter THREE = 3;
  parameter FOUR  = 4;
  parameter FIVE  = 5;
  parameter SIX   = 6;
  parameter SEVEN = 7;
  parameter EIGHT = 8;

  parameter KEY_128_BITS = 0;
  parameter KEY_256_BITS = 1;

  parameter EIGHT_ROUNDS  = 8;
  parameter TWELWE_ROUNDS = 12;
  parameter TWENTY_ROUNDS = 20;

  parameter DISABLE = 0;
  parameter ENABLE  = 1;


  //----------------------------------------------------------------
  // Register and Wire declarations.
  //----------------------------------------------------------------
  reg [31 : 0] cycle_ctr;
  reg [31 : 0] error_ctr;
  reg [31 : 0] tc_ctr;

  reg tb_clk;
  reg tb_reset_n;

  reg            tb_core_init;
  reg            tb_core_next;
  reg [255 : 0]  tb_core_key;
  reg            tb_core_keylen;
  reg [4 : 0]    tb_core_rounds;
  reg [63 : 0]   tb_core_iv;
  wire           tb_core_ready;
  reg [0 : 511]  tb_core_data_in;
  wire [0 : 511] tb_core_data_out;

  reg            display_cycle_ctr;
  reg            display_ctrl_and_ctrs;
  reg            display_qround;
  reg            display_state;
  reg            display_x_state;


  //----------------------------------------------------------------
  // salsa20_core device under test.
  //----------------------------------------------------------------
  salsa20_core dut(
                   // Clock and reset.
                   .clk(tb_clk),
                   .reset_n(tb_reset_n),

                   // Control.
                   .init(tb_core_init),
                   .next(tb_core_next),

                   // Parameters.
                   .key(tb_core_key),
                   .keylen(tb_core_keylen),
                   .iv(tb_core_iv),
                   .rounds(tb_core_rounds),

                   // Data input.
                   .data_in(tb_core_data_in),

                   // Status output.
                   .ready(tb_core_ready),

                   // Data out with valid signal.
                   .data_out(tb_core_data_out),
                   .data_out_valid(tb_core_data_out_valid)
                  );


  //----------------------------------------------------------------
  // clk_gen
  //
  // Clock generator process.
  //----------------------------------------------------------------
  always
    begin : clk_gen
      #CLK_HALF_PERIOD tb_clk = !tb_clk;
    end // clk_gen


  //--------------------------------------------------------------------
  // dut_monitor
  //
  // Monitor that displays different types of information
  // every cycle depending on what flags test cases enable.
  //
  // The monitor includes a cycle counter for the testbench.
  //--------------------------------------------------------------------
  always @ (posedge tb_clk)
    begin : dut_monitor
      cycle_ctr = cycle_ctr + 1;

      // Display cycle counter.
      if (display_cycle_ctr)
        begin
          $display("cycle = %08x:", cycle_ctr);
          $display("");
        end

      // Display FSM control state and QR, DR counters.
      if (display_ctrl_and_ctrs)
        begin
          $display("salsa20_ctrl_reg = %01x", dut.salsa20_ctrl_reg);
          $display("qr_ctr_reg = %01x, dr_ctr_reg = %01x", dut.qr_ctr_reg, dut.dr_ctr_reg);
          $display("");
        end

      // Display the internal state register.
      if (display_state)
        begin
//          $display("Internal state:");
//          $display("0x%064x", dut.state_reg);
//          $display("");
        end

      // Display the round processing state register X.
      if (display_x_state)
        begin
          $display("Round state X:");
          $display("x0_reg   = 0x%08x, x0_new   = 0x%08x, x0_we  = 0x%01x", dut.x0_reg,  dut.x0_new,  dut.x0_we);
          $display("x1_reg   = 0x%08x, x1_new   = 0x%08x, x1_we  = 0x%01x", dut.x1_reg,  dut.x1_new,  dut.x1_we);
          $display("x2_reg   = 0x%08x, x2_new   = 0x%08x, x2_we  = 0x%01x", dut.x2_reg,  dut.x2_new,  dut.x2_we);
          $display("x3_reg   = 0x%08x, x3_new   = 0x%08x, x3_we  = 0x%01x", dut.x3_reg,  dut.x3_new,  dut.x3_we);
          $display("x4_reg   = 0x%08x, x4_new   = 0x%08x, x4_we  = 0x%01x", dut.x4_reg,  dut.x4_new,  dut.x4_we);
          $display("x5_reg   = 0x%08x, x5_new   = 0x%08x, x5_we  = 0x%01x", dut.x5_reg,  dut.x5_new,  dut.x5_we);
          $display("x6_reg   = 0x%08x, x6_new   = 0x%08x, x6_we  = 0x%01x", dut.x6_reg,  dut.x6_new,  dut.x6_we);
          $display("x7_reg   = 0x%08x, x7_new   = 0x%08x, x7_we  = 0x%01x", dut.x7_reg,  dut.x7_new,  dut.x7_we);
          $display("x8_reg   = 0x%08x, x8_new   = 0x%08x, x8_we  = 0x%01x", dut.x8_reg,  dut.x8_new,  dut.x8_we);
          $display("x9_reg   = 0x%08x, x9_new   = 0x%08x, x9_we  = 0x%01x", dut.x9_reg,  dut.x9_new,  dut.x9_we);
          $display("x10_reg  = 0x%08x, x10_new  = 0x%08x, x10_we = 0x%01x", dut.x10_reg, dut.x10_new, dut.x10_we);
          $display("x11_reg  = 0x%08x, x11_new  = 0x%08x, x11_we = 0x%01x", dut.x11_reg, dut.x11_new, dut.x11_we);
          $display("x12_reg  = 0x%08x, x12_new  = 0x%08x, x12_we = 0x%01x", dut.x12_reg, dut.x12_new, dut.x12_we);
          $display("x13_reg  = 0x%08x, x13_new  = 0x%08x, x13_we = 0x%01x", dut.x13_reg, dut.x13_new, dut.x13_we);
          $display("x14_reg  = 0x%08x, x14_new  = 0x%08x, x14_we = 0x%01x", dut.x14_reg, dut.x14_new, dut.x14_we);
          $display("x15_reg  = 0x%08x, x15_new  = 0x%08x, x15_we = 0x%01x", dut.x15_reg, dut.x15_new, dut.x15_we);
          $display("");
        end

      // Display the qround input and outputs.
      if (display_qround)
        begin
          $display("a      = %08x, b      = %08x, c      = %08x, d      = %08x", dut.qr0_a, dut.qr0_b, dut.qr0_c, dut.qr0_d);
          $display("qr0_a_prim = %08x, qr0_b_prim = %08x, qr0_c_prim = %08x, qr0_d_prim = %08x", dut.qr0_a_prim, dut.qr0_b_prim, dut.qr0_c_prim, dut.qr0_d_prim);
          $display("");
        end

    end // dut_monitor


  //----------------------------------------------------------------
  // dump_state()
  // Dump the internal SALSA20 state to std out.
  //----------------------------------------------------------------
  task dump_state;
    begin
      $display("");
      $display("Internal state:");
      $display("---------------");
//      $display("0x%064x", dut.state_reg);
//      $display("");

      $display("Round state X::");
      $display("x0_reg  = %08x, x1_reg  = %08x", dut.x0_reg, dut.x1_reg);
      $display("x2_reg  = %08x, x3_reg  = %08x", dut.x2_reg, dut.x3_reg);
      $display("x4_reg  = %08x, x5_reg  = %08x", dut.x4_reg, dut.x5_reg);
      $display("x6_reg  = %08x, x7_reg  = %08x", dut.x6_reg, dut.x7_reg);
      $display("x8_reg  = %08x, x9_reg  = %08x", dut.x8_reg, dut.x9_reg);
      $display("x10_reg = %08x, x11_reg = %08x", dut.x10_reg, dut.x11_reg);
      $display("x12_reg = %08x, x13_reg = %08x", dut.x12_reg, dut.x13_reg);
      $display("x14_reg = %08x, x15_reg = %08x", dut.x14_reg, dut.x15_reg);
      $display("");

      $display("rounds_reg = %01x", dut.rounds_reg);
      $display("qr_ctr_reg = %01x, dr_ctr_reg  = %01x", dut.qr_ctr_reg, dut.dr_ctr_reg);
      $display("block0_ctr_reg = %08x, block1_ctr_reg = %08x", dut.block0_ctr_reg, dut.block1_ctr_reg);

      $display("");

      $display("salsa20_ctrl_reg = %02x", dut.salsa20_ctrl_reg);
      $display("");

      $display("data_in_reg = %064x", dut.data_in_reg);
      $display("data_out_valid_reg = %01x", dut.data_out_valid_reg);
      $display("");

      $display("qr0_a_prim = %08x, qr0_b_prim = %08x", dut.qr0_a_prim, dut.qr0_b_prim);
      $display("qr0_c_prim = %08x, qr0_d_prim = %08x", dut.qr0_c_prim, dut.qr0_d_prim);
      $display("");
    end
  endtask // dump_state


  //----------------------------------------------------------------
  // dump_inout()
  // Dump the status for input and output ports.
  //----------------------------------------------------------------
  task dump_inout;
    begin
      $display("");
      $display("State for input and output ports:");
      $display("---------------------------------");

      $display("init       = %01x", dut.init);
      $display("next       = %01x", dut.next);
      $display("keylen     = %01x", dut.keylen);
      $display("");

      $display("key = %032x", dut.key);
      $display("iv  = %016x", dut.iv);
      $display("");

      $display("ready          = %01x", dut.ready);
      $display("data_in        = %064x", dut.data_in);
      $display("data_out       = %064x", dut.data_out);
      $display("data_out_valid = %01x", dut.data_out_valid);
      $display("");
    end
  endtask // dump_inout


  //----------------------------------------------------------------
  // set_core_init()
  //
  // Set core init flag to given value.
  //----------------------------------------------------------------
  task set_core_init(input value);
    begin
      tb_core_init = value;
    end
  endtask // set_core_init


  //----------------------------------------------------------------
  // set_core_next()
  //
  // Set code next flag to given value.
  //----------------------------------------------------------------
  task set_core_next(input value);
    begin
      tb_core_next = value;
    end
  endtask // set_core_next


  //----------------------------------------------------------------
  // set_core_key_iv_rounds()
  //
  // Sets the core key, iv and rounds indata ports
  // to the given values.
  //----------------------------------------------------------------
  task set_core_key_iv_rounds(input [255 : 0] key,
                              input           key_length,
                              input [63 : 0]  iv,
                              input [4 : 0]   rounds);
    begin
      tb_core_key    = key;
      tb_core_keylen = key_length;
      tb_core_iv     = iv;
      tb_core_rounds = rounds;
    end
  endtask // set_core_key_iv


  //----------------------------------------------------------------
  // cycle_reset()
  //
  // Cycles the reset signal on the dut.
  //----------------------------------------------------------------
  task cycle_reset;
    begin
      tb_reset_n = 0;
      #(2 * CLK_HALF_PERIOD);

      @(negedge tb_clk)

      tb_reset_n = 1;
      #(2 * CLK_HALF_PERIOD);
    end
  endtask // cycle_reset


  //----------------------------------------------------------------
  // run_test_case
  //
  // Runs a test case based on the given key, keylenght, IV and
  // expected data out from the DUT.
  //----------------------------------------------------------------
  task run_test_case(input [7 : 0]   major,
                     input [7 : 0]   minor,
                     input [255 : 0] key,
                     input           key_length,
                     input [63 : 0]  iv,
                     input [4 : 0]   rounds,
                     input [511 : 0] expected);
    begin
      $display("*** TC %0d-%0d started.", major, minor);
      $display("");

      tc_ctr = tc_ctr + 1;

      cycle_reset();
      set_core_key_iv_rounds(key, key_length, iv, rounds);
      set_core_init(1);

      #(2 * CLK_HALF_PERIOD);
      set_core_init(0);
      dump_state();

      // Wait for valid flag and check results.
      @(posedge dut.data_out_valid);
      dump_state();

      if (tb_core_data_out == expected)
        begin
          $display("*** TC %0d-%0d successful", major, minor);
          $display("");
        end
      else
        begin
          $display("*** ERROR: TC %0d-%0d not successful", major, minor);
          $display("Expected: 0x%064x", expected);
          $display("Got:      0x%064x", tb_core_data_out);
          $display("");

          error_ctr = error_ctr + 1;
        end
    end
  endtask // run_test_case


  //----------------------------------------------------------------
  // display_test_result()
  //
  // Display the accumulated test results.
  //----------------------------------------------------------------
  task display_test_result;
    begin
      if (error_ctr == 0)
        begin
          $display("*** All %d test cases completed successfully", tc_ctr);
        end
      else
        begin
          $display("*** %02d test cases did not complete successfully.", error_ctr);
        end
    end
  endtask // display_test_result


  //----------------------------------------------------------------
  // init_dut()
  //
  // Set the input to the DUT to defined values.
  //----------------------------------------------------------------
  task init_dut;
    begin
      cycle_ctr         = 0;
      tb_clk            = 0;
      tb_reset_n        = 0;
      error_ctr         = 0;
      tc_ctr            = 0;
      set_core_key_iv_rounds(256'h0000000000000001000000000000000100000000000000010000000000000001,
                        1'b0,
                        64'h0000000000000001,
                        5'b01000);

      tb_core_init      = 0;
      tb_core_next      = 0;
      tb_core_data_in   = 512'h0;
    end
  endtask // init_dut


  //----------------------------------------------------------------
  // set_display_prefs()
  //
  // Set the different monitor displays we want to see during
  // simulation.
  //----------------------------------------------------------------
  task set_display_prefs(
                         input cycles,
                         input ctrl_ctr,
                         input state,
                         input x_state,
                         input qround);
    begin
      display_cycle_ctr     = cycles;
      display_ctrl_and_ctrs = ctrl_ctr;
      display_state         = state;
      display_x_state       = x_state;
      display_qround        = qround;
    end
  endtask // set_display_prefs


  //----------------------------------------------------------------
  // salsa20_core_test
  //
  // The main test functionality.
  //----------------------------------------------------------------
  initial
    begin : salsa20_core_test
      $display("   -- Testbench for salsa20_core started --");
      $display("");

      set_display_prefs(0, 0, 1, 1, 0);
      init_dut();
      $display("*** State at init:");
      $display("");
      dump_state();

      #(4 * CLK_HALF_PERIOD);
      @(negedge tb_clk)
      tb_reset_n = 1;
      #(2 * CLK_HALF_PERIOD);
      $display("*** State after release of reset:");
      $display("");
      dump_state();

      $display("TC1-1: All zero inputs. 128 bit key, 8 rounds.");
      run_test_case(TC1, ONE,
                    256'h0000000000000000000000000000000000000000000000000000000000000000,
                    KEY_128_BITS,
                    64'h0000000000000000,
                    EIGHT_ROUNDS,
                    512'he28a5fa4a67f8c5defed3e6fb7303486aa8427d31419a729572d777953491120b64ab8e72b8deb85cd6aea7cb6089a101824beeb08814a428aab1fa2c816081b);


     $display("TC1-2: All zero inputs. 128 bit key, 12 rounds.");
      run_test_case(TC1, TWO,
                    256'h0000000000000000000000000000000000000000000000000000000000000000,
                    KEY_128_BITS,
                    64'h0000000000000000,
                    TWELWE_ROUNDS,
                    512'he1047ba9476bf8ff312c01b4345a7d8ca5792b0ad467313f1dc412b5fdce32410dea8b68bd774c36a920f092a04d3f95274fbeff97bc8491fcef37f85970b450);


     $display("TC1-3: All zero inputs. 128 bit key, 20 rounds.");
      run_test_case(TC1, THREE,
                    256'h0000000000000000000000000000000000000000000000000000000000000000,
                    KEY_128_BITS,
                    64'h0000000000000000,
                    TWENTY_ROUNDS,
                    512'h89670952608364fd00b2f90936f031c8e756e15dba04b8493d00429259b20f46cc04f111246b6c2ce066be3bfb32d9aa0fddfbc12123d4b9e44f34dca05a103f);


      $display("TC1-4: All zero inputs. 256 bit key, 8 rounds.");
      run_test_case(TC1, FOUR,
                    256'h0000000000000000000000000000000000000000000000000000000000000000,
                    KEY_256_BITS,
                    64'h0000000000000000,
                    EIGHT_ROUNDS,
                    512'h3e00ef2f895f40d67f5bb8e81f09a5a12c840ec3ce9a7f3b181be188ef711a1e984ce172b9216f419f445367456d5619314a42a3da86b001387bfdb80e0cfe42);


      $display("TC1-5: All zero inputs. 256 bit key, 12 rounds.");
      run_test_case(TC1, FIVE,
                    256'h0000000000000000000000000000000000000000000000000000000000000000,
                    KEY_256_BITS,
                    64'h0000000000000000,
                    TWELWE_ROUNDS,
                    512'h9bf49a6a0755f953811fce125f2683d50429c3bb49e074147e0089a52eae155f0564f879d27ae3c02ce82834acfa8c793a629f2ca0de6919610be82f411326be);


      $display("TC1-6: All zero inputs. 256 bit key, 20 rounds.");
      run_test_case(TC1, SIX,
                    256'h0000000000000000000000000000000000000000000000000000000000000000,
                    KEY_256_BITS,
                    64'h0000000000000000,
                    TWENTY_ROUNDS,
                    512'h76b8e0ada0f13d90405d6ae55386bd28bdd219b8a08ded1aa836efcc8b770dc7da41597c5157488d7724e03fb8d84a376a43b8f41518a11cc387b669b2ee6586);


      $display("TC2-1: One bit in key set, all zero IV. 128 bit key, 8 rounds.");
      run_test_case(TC2, ONE,
                    256'h0100000000000000000000000000000000000000000000000000000000000000,
                    KEY_128_BITS,
                    64'h0000000000000000,
                    EIGHT_ROUNDS,
                    512'h03a7669888605a0765e8357475e58673f94fc8161da76c2a3aa2f3caf9fe5449e0fcf38eb882656af83d430d410927d55c972ac4c92ab9da3713e19f761eaa14);


      $display("TC2-2: One bit in key set, all zero IV. 256 bit key, 8 rounds.");
      run_test_case(TC2, ONE,
                    256'h0100000000000000000000000000000000000000000000000000000000000000,
                    KEY_256_BITS,
                    64'h0000000000000000,
                    EIGHT_ROUNDS,
                    512'hcf5ee9a0494aa9613e05d5ed725b804b12f4a465ee635acc3a311de8740489ea289d04f43c7518db56eb4433e498a1238cd8464d3763ddbb9222ee3bd8fae3c8);


      $display("TC3-1: All zero key, one bit in IV set. 128 bit key, 8 rounds.");
      run_test_case(TC3, ONE,
                    256'h0000000000000000000000000000000000000000000000000000000000000000,
                    KEY_128_BITS,
                    64'h0100000000000000,
                    EIGHT_ROUNDS,
                    512'h25f5bec6683916ff44bccd12d102e692176663f4cac53e719509ca74b6b2eec85da4236fb29902012adc8f0d86c8187d25cd1c486966930d0204c4ee88a6ab35);


      $display("TC4-1: All bits in key and IV are set. 128 bit key, 8 rounds.");
      run_test_case(TC4, ONE,
                    256'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff,
                    KEY_128_BITS,
                    64'hffffffffffffffff,
                    EIGHT_ROUNDS,
                    512'h2204d5b81ce662193e00966034f91302f14a3fb047f58b6e6ef0d721132304163e0fb640d76ff9c3b9cd99996e6e38fad13f0e31c82244d33abbc1b11e8bf12d);


      $display("TC5-1: Even bits in key, IV are set. 128 bit key, 8 rounds.");
      run_test_case(TC5, ONE,
                    256'h5555555555555555555555555555555555555555555555555555555555555555,
                    KEY_128_BITS,
                    64'h5555555555555555,
                    EIGHT_ROUNDS,
                    512'hf0a23bc36270e18ed0691dc384374b9b2c5cb60110a03f56fa48a9fbbad961aa6bab4d892e96261b6f1a0919514ae56f86e066e17c71a4176ac684af1c931996);


      $display("TC6-1: Odd bits in key, IV are set. 128 bit key, 8 rounds.");
      run_test_case(TC6, ONE,
                    256'haaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa,
                    KEY_128_BITS,
                    64'haaaaaaaaaaaaaaaa,
                    EIGHT_ROUNDS,
                    512'h312d95c0bc38eff4942db2d50bdc500a30641ef7132db1a8ae838b3bea3a7ab03815d7a4cc09dbf5882a3433d743aced48136ebab73299506855c0f5437a36c6);


      $display("TC7-1: Increasing, decreasing sequences in key and IV. 128 bit key, 8 rounds");
      run_test_case(TC7, ONE,
                    256'h00112233445566778899aabbccddeeff00000000000000000000000000000000,
                    KEY_128_BITS,
                    64'h0f1e2d3c4b596877,
                    EIGHT_ROUNDS,
                    512'ha7a6c81bd8ac106e8f3a46a1bc8ec702e95d18c7e0f424519aeafb54471d83a2bf888861586b73d228eaaf82f9665a5a155e867f93731bfbe24fab495590b231);


      $display("TC7-2: Increasing, decreasing sequences in key and IV. 256 bit key, 8 rounds.");
      run_test_case(TC7, TWO,
                    256'h00112233445566778899aabbccddeeffffeeddccbbaa99887766554433221100,
                    KEY_256_BITS,
                    64'h0f1e2d3c4b596877,
                    EIGHT_ROUNDS,
                    512'h60fdedbd1a280cb741d0593b6ea0309010acf18e1471f68968f4c9e311dca149b8e027b47c81e0353db013891aa5f68ea3b13dd2f3b8dd0873bf3746e7d6c567);


      $display("TC8-128-8: Random inputs. 128 bit key, 8 rounds.");
      run_test_case(TC8, ONE,
                    256'hc46ec1b18ce8a878725a37e780dfb73500000000000000000000000000000000,
                    KEY_128_BITS,
                    64'h1ada31d5cf688221,
                    EIGHT_ROUNDS,
                    512'h6a870108859f679118f3e205e2a56a6826ef5a60a4102ac8d4770059fcb7c7bae02f5ce004a6bfbbea53014dd82107c0aa1c7ce11b7d78f2d50bd3602bbd2594);


      // Finish in style.
      $display("*** salsa20_core simulation done ***");
      display_test_result();
      $finish;
    end // salsa20_core_test

endmodule // tb_salsa20_core

//======================================================================
// EOF tb_salsa20_core.v
//======================================================================
