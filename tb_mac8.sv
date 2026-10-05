`timescale 1ns/1ps

interface mac_if(input logic clk);
    logic rst;
    logic valid;
    logic signed [7:0] a;
    logic signed [7:0] b;
    logic signed [31:0] acc;
endinterface


class transaction;

    rand logic signed [7:0] a;
    rand logic signed [7:0] b;

    constraint range {
        a inside {[-20:20]};
        b inside {[-20:20]};
    }

endclass


class generator;

    mailbox #(transaction) mbx;

    function new(mailbox #(transaction) mbx);
        this.mbx = mbx;
    endfunction

    task run();

        transaction tr;

        repeat(20) begin

            tr = new();

            if (!tr.randomize())
                $fatal("Randomization failed");

            $display(
                "GEN: A=%0d B=%0d",
                tr.a,
                tr.b
            );

            mbx.put(tr);

        end

    endtask

endclass


class driver;

    virtual mac_if vif;
    mailbox #(transaction) mbx;

    function new(
        virtual mac_if vif,
        mailbox #(transaction) mbx
    );

        this.vif = vif;
        this.mbx = mbx;

    endfunction

    task run();

        transaction tr;

        forever begin

            mbx.get(tr);

            @(negedge vif.clk);

            vif.a     = tr.a;
            vif.b     = tr.b;
            vif.valid = 1;

            @(negedge vif.clk);

            vif.valid = 0;

        end

    endtask

endclass


class checker;

    virtual mac_if vif;

    logic signed [31:0] expected_acc;

    int checked;
    int errors;

    function new(virtual mac_if vif);

        this.vif = vif;

        expected_acc = 0;
        checked = 0;
        errors = 0;

    endfunction

    task run();

        forever begin

            @(posedge vif.clk);

            if (!vif.rst && vif.valid) begin

                expected_acc =
                    expected_acc +
                    ($signed(vif.a) * $signed(vif.b));

                #1;

                checked++;

                if (vif.acc !== expected_acc) begin

                    errors++;

                    $display(
                        "FAIL: A=%0d B=%0d EXPECTED=%0d ACTUAL=%0d",
                        vif.a,
                        vif.b,
                        expected_acc,
                        vif.acc
                    );

                end
                else begin

                    $display(
                        "PASS: A=%0d B=%0d ACC=%0d",
                        vif.a,
                        vif.b,
                        vif.acc
                    );

                end

            end

        end

    endtask

endclass


module tb_mac8;

    parameter CLK_PERIOD = 10;

    logic clk;

    mac_if intf(clk);

    mac8 dut (
        .clk   (clk),
        .rst   (intf.rst),
        .valid (intf.valid),
        .a     (intf.a),
        .b     (intf.b),
        .acc   (intf.acc)
    );

    mailbox #(transaction) mbx;

    generator gen;
    driver drv;
    checker chk;


    initial
        clk = 0;

    always #(CLK_PERIOD/2)
        clk = ~clk;


    initial begin

        intf.rst   = 1;
        intf.valid = 0;
        intf.a     = 0;
        intf.b     = 0;

        repeat(2)
            @(posedge clk);

        @(negedge clk);

        intf.rst = 0;

    end


    initial begin

        mbx = new();

        gen = new(mbx);

        drv = new(
            intf,
            mbx
        );

        chk = new(intf);


        wait(intf.rst == 0);


        fork

            drv.run();

            chk.run();

        join_none


        gen.run();


        wait(chk.checked == 20);


        $display("");
        $display("TEST COMPLETE");

        $display(
            "Checked = %0d",
            chk.checked
        );

        $display(
            "Errors  = %0d",
            chk.errors
        );


        if (chk.errors == 0)
            $display("RESULT = PASS");
        else
            $display("RESULT = FAIL");


        $finish;

    end

endmodule
