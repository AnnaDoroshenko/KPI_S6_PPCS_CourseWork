--------------------------------------------------------------------------------
-- Programming for Parallel Computer Systems --
-- Course Work. Program 2 --
-- Ada. Rendezvous --

-- R = min(X) * (MA*MB) * T + e * Z --

-- Author: Anna Doroshenko --
-- Group: IO-52 --
-- Date: 22.04.2018 --
--------------------------------------------------------------------------------
with Data, Ada.Text_IO, Ada.Integer_Text_IO, Ada.Float_Text_IO, Ada.Synchronous_Task_Control,
-- Ada.Numerics.Generic_Elementary_Functions,
Ada.Calendar;
use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Float_Text_IO, Ada.Synchronous_Task_Control,
-- Ada.Numerics.Generic_Elementary_Functions,
Ada.Calendar;

procedure CourseWork is

    STORAGE : constant Integer := 50000000;
    POWER : constant Integer := 3;         -- power of 2
    P : constant Integer := 2**POWER;      -- size of vector and matrix
    -- N : constant Integer := 2 * P;             -- amount of the processors
    N : constant Integer := 8;             -- amount of the processors
    H : constant Integer := N/P;           -- size of the subvector and the submatrix
    DIRECT_DATA: constant Boolean := true;
    REVERSED_DATA: constant Boolean := false;

    package NewData is new Data(POWER, N, H);
    use NewData;

    procedure Task_Launch is

    task type Ti is
        pragma Storage_Size(STORAGE);

        entry Start(tid_in: in Integer);

        entry DataMB_e(MB: in Matrix; e: in Integer);
        entry DataMA_X_T_Z(MA: in Matrix; X: in Vector; T: in Vector; Z: in Vector);
        entry Data_a(a: in Integer);

        entry SearchMin(a_prev: in Integer);
        entry Res_R(R: out Vector);
    end Ti;

    type ti_array is array (1..P) of Ti;
    tasks : Ti_array;
    -----------------------------------
    task body Ti is
        tid : Integer;
        tidBin : Vertex;
        j: Integer;

        MAi: access Matrix;
        MBi: access Matrix;
        Xi: access Vector;
        Ti: access Vector;
        Zi: access Vector;
        ei: Integer;
        Ri: access Vector;
        ai: Integer;

        M_buff: access Matrix;
        V_buff1: access Vector;
        V_buff2: access Vector;
        buff1: Integer;
        buff2: Integer;

        sizeDirect: Integer;
        sizeReversed: Integer;

    begin
        accept Start(tid_in: Integer) do
            tid := tid_in;
            tidBin := getVertexNumber(tid);
        end Start;
        Put_Line("T" & Integer'Image(tid) & " started");

        -- Init variables
        sizeDirect := getDataSizeInHs(tidBin, DIRECT_DATA) * H;
        sizeReversed := getDataSizeInHs(tidBin, REVERSED_DATA) * H;
        M_buff := new Matrix(1..N/2);
        V_buff1 := new Vector(1..N/2);
        V_buff2 := new Vector(1..N/2);
        MAi := new Matrix(1..N);
        MBi := new Matrix(1..sizeDirect);
        Xi := new Vector(1..sizeReversed);
        Ti := new Vector(1..N);
        Zi := new Vector(1..sizeReversed);
        Ri := new Vector(1..sizeDirect);

        -- input data
        if (tid = 1) then
            FillMatrixWithOnes(MBi);
            ei := 1;
        elsif (tid = P) then
            FillMatrixWithOnes(MAi);
            FillVectorWithOnes(Xi);
            FillVectorWithOnes(Ti);
            FillVectorWithOnes(Zi);
        end if;

        -- get position of righmost 1 or 0
        j := getPositionOfJ(tidBin);

        -- Flat wave. Receive
        if (j /= 0) then
            if (isDirect(tidBin)) then
                -- receive MB, e
                accept DataMB_e(MB: in Matrix; e: in Integer) do
                    MBi.all(1..sizeDirect) := MB(1..sizeDirect);
                    ei := e;
                end DataMB_e;
            else
                --receive MA, X, T, Z
                accept DataMA_X_T_Z(MA: in Matrix; X: in Vector; T: in Vector; Z: in Vector) do
                    MAi.all(1..N) := MA(1..N);
                    Xi.all(1..sizeReversed) := X(1..sizeReversed);
                    Ti.all(1..N) := T(1..N);
                    Zi.all(1..sizeReversed) := Z(1..sizeReversed);
                end DataMA_X_T_Z;
            end if;
        end if;

        -- Flat wave. Send
        buff1 := 0; -- getWeight(pos) * H
        buff2 := 0; -- for reversed. shift
        for pos in j+1..POWER-1 loop -- HERE
            buff1 := getWeight(pos) * H;
            if (isDirect(tidBin)) then
                -- send MB, e
                M_buff.all(1..buff1) := MBi.all(buff1+1..2*buff1);
                tasks(getTid(toggle(tidBin, pos)))
                    .DataMB_e(M_buff.all(1..buff1), ei);
            else
                -- send MA, X, T, Z
                V_buff1.all(1..buff1) := Xi.all(buff2+1..buff2+buff1);
                V_buff2.all(1..buff1) := Zi.all(buff2+1..buff2+buff1);
                buff2 := buff2 + buff1; -- for next iteration
                tasks(getTid(toggle(tidBin, pos)))
                    .DataMA_X_T_Z(MAi.all(1..N), V_buff1.all(1..buff1),
                        Ti.all(1..N), V_buff2.all(1..buff1));
            end if;
        end loop;

        -- Vertical wave
        if (isDirect(tidBin)) then
            -- send MB, e
            M_buff.all(1..H) := MBi.all(H+1..2*H);
            tasks(getTid(toggle(tidBin, POWER)))
                .DataMB_e(M_buff.all(1..H), ei);

            -- receive MA, X, T, Z
            accept DataMA_X_T_Z(MA: in Matrix; X: in Vector; T: in Vector; Z: in Vector) do
                MAi.all(1..N) := MA(1..N);
                Xi.all(1..H) := X(1..H);
                Ti.all(1..N) := T(1..N);
                Zi.all(1..H) := Z(1..H);
            end DataMA_X_T_Z;
        else
            -- receive MB, e
            accept DataMB_e(MB: in Matrix; e: in Integer) do
                MBi.all(1..H) := MB(1..H);
                ei := e;
            end DataMB_e;

            -- send MA, X, T, Z
            V_buff1.all(1..H) := Xi.all(sizeReversed-2*H+1..sizeReversed-H);
            V_buff2.all(1..H) := Zi.all(sizeReversed-2*H+1..sizeReversed-H);
            tasks(getTid(toggle(tidBin, POWER)))
                .DataMA_X_T_Z(MAi.all(1..N), V_buff1.all(1..H),
                    Ti.all(1..N), V_buff2.all(1..H));
        end if;

        -- place self pieces into 1..H (only needed for reversed ones)
        if (not isDirect(tidBin)) then
            Xi(1..H) := Xi(sizeReversed-H+1..sizeReversed);
            Zi(1..H) := Zi(sizeReversed-H+1..sizeReversed);
        end if;

        -- calculation of min
        ai := SearchMinElemOFVector(Xi);

        -- calculation of total min
        j := getPositionOfRightmost(tidBin, 1);
        -- Receive ai
        for i in reverse j+1..POWER loop
            accept SearchMin(a_prev: in Integer) do
                ai := SearchTotalMin(a_prev, ai);
            end SearchMin;
        end loop;

        -- Send ai
        if (j > 0) then
            tasks(getTid(toggle(tidBin, j))).SearchMin(ai);
        end if;

        -- Distribute total min a
        j := getPositionOfRightmost(tidBin, 1);
        -- Receive a
        if (j > 0) then
            accept Data_a(a: in Integer) do
                ai := a;
            end Data_a;
        end if;

        -- Send a
        for i in j+1..POWER loop
            tasks(getTid(toggle(tidBin, i))).Data_a(ai);
        end loop;

        -- main calculations
        for t in 1..H loop
            buff1 := 0;
            for i in 1..N loop
                buff2 := 0;
                for k in 1..N loop
                    buff2 := buff2 + MBi(t)(k) * MAi(k)(i);
                end loop;

                buff1 := buff1 + Ti(i) * buff2;
            end loop;
            Ri(t) := ai * buff1 + ei * Zi(t);
        end loop;

        -- get total result
        j := getPositionOfRightmost(tidBin, 1);
        -- Receive Ri
        buff1 := H; -- both shift and receive size
        for i in reverse j+1..POWER loop
            tasks(getTid(toggle(tidBin, i))).Res_R(V_buff1.all);

            Ri.all(buff1+1..2*buff1) := V_buff1.all(1..buff1);
            buff1 := buff1 * 2;
        end loop;

        -- Send Ri
        if (j > 0) then
            accept Res_R(R: out Vector) do
                R(1..sizeDirect) := Ri.all(1..sizeDirect);
            end Res_R;
        end if;

        if (tid = 1 and N <= 8) then
            OutputVector(Ri, N);
        end if;

            Put_Line("T" & Integer'Image(tid) & " finished");
        end Ti;
        -------------------------------------------------------
        begin
            -- create tasks
            for i in 1..P loop
                tasks(i).Start(i);
            end loop;
        end Task_Launch;

        -- Body of main programm
        begin
            -- Put_Line("Course Work started");
            Task_Launch;
            -- Put_Line("Course Work finished");
        end CourseWork;

