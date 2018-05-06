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
    N : constant Integer := 1 * P;             -- amount of the processors
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
        -- entry Data_a(a: in Integer);
        --
        -- entry SearchMin(A: out Integer);
        -- entry Res_R(R: out Vector);
    end Ti;

    type ti_array is array (1..P) of Ti;
    tasks : Ti_array;
    -----------------------------------
    task body Ti is
        tid : Integer;
        tidBin : Vertex;
        j: Integer;

        M_buff: access Matrix;
        V_buff1: access Vector;
        V_buff2: access Vector;
        buff1: Integer;
        buff2: Integer;

        MAi: access Matrix;
        MBi: access Matrix;
        Xi: access Vector;
        Ti: access Vector;
        Zi: access Vector;
        ei: Integer;

        sizeDirect: Integer;
        sizeReversed: Integer;

        -- Ri: Vector;
        -- ai, a_previous: Integer;

    begin
        accept Start(tid_in: Integer) do
            tid := tid_in;
            tidBin := getVertexNumber(tid);
        end Start;
        -- Put_Line("T" & Integer'Image(tid) & " started");

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

        buff1 := 0; -- getWeight(pos)
        buff2 := 0; -- for reversed. shift
        for pos in j+1..POWER-1 loop -- HERE
            buff1 := getWeight(pos);
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

        -- place self pieces into 1..H
        if (not isDirect(tidBin)) then
            Xi(1..H) := Xi(sizeReversed-H+1..sizeReversed);
            Zi(1..H) := Zi(sizeReversed-H+1..sizeReversed);
        end if;

        -- if (tid = 4) then
        -- if (tid rem 2 = 0) then
            -- Put_Line(Integer'Image(tid) & " got " & Integer'Image(j+1));
            -- Put_Line(Integer'Image(tid) & " got " & Integer'Image(Ti(1)));
            -- Put_Line(Integer'Image(tid) & " got " & Integer'Image(MBi(1)(1)));
            -- OutputVector(Zi, 4);
        -- end if;

        -- if (isDirect(tidBin)) then
        --     -- send MB, e
        --     T(toggle(TidBin, L)).DataMB(MBi(1..getWeight(l)*H), ei);
        --
        --     -- receive MA, X, T, Z
        --     accept DataMA_X_T_Z(MA: in Matrix; X: in Vector; T: in Vector; Z: in Vector) do
        --         MAi(1..N) := MA(1..N);
        --         Xi(1..getWeight(l)*H) := X(1..getWeight(l)*H);
        --         Ti(1..N) := T(1..N);
        --         Zi(1..getWeight(l)*H) := Z(1..getWeight(l)*H);
        --     end DataMA_X_T_Z;
        -- else
        --     -- receive MB, e
        --     accept DataMB_e(MB: in Matrix; e: in Integer) do
        --         MBi(1..getWeigt(L)*H) := MB(1..getWeigt(L)*H);
        --         ei := e;
        --     end DataMB_e;
        --
        --     -- send MA, X, T, Z
        --     T(toggle(TidBin, L)).DataMA_X_T_Z(MA(1..N), Xi(1..getWeight(l)*H), Ti(1..N), Zi(1..getWeight(l)*H));
        -- end if;
        --
        -- -- calculation of min
        -- ai := SearchMinElemOFVector(X1(1..H));
        --
        -- -- calculation of total min
        -- j := positionOfRightmost1(tidBin);
        -- if (j = -1) then
        --     j := 0;
        --     for i in L..j+1 loop
        --         -- receive ai
        --         T(toggle(TidBin, I)).SearchMin(A_previous);
        --
        --         Ai := SearchTotalMin(a_previous, ai);
        --     end loop;
        -- end if;
        --
        -- if (j > 0) then
        --     -- send ai
        --     accept SearchMin(A: out Integer) do
        --         ai := A;
        --     end SearchMin;
        -- end if;
        --
        -- if (isDirect(tidBin)) then
        --     if (j /= -1) then
        --         -- receive a
        --         accept Data_a(a: in Integer) do
        --             Ai := A;
        --         end Data_a;
        --     else
        --         j := 0;
        --         for i in j+1..l loop
        --             -- send a
        --             T(toggle(TidBin, i)).SearchMin(Ai);
        --         end loop;
        --     end if;
        -- end if;
        --
        -- -- main calculations
        -- AddVectors(Ri(1..H),MultScalarVector(ai, MultVectorMatrix(T(1..N),
        -- MultMatrices(MBi(1..H), MAi(1..N)))),MultScalarVector(ei, Zi(1..H)));
        --
        -- -- get total result
        -- j := positionOfRightmost1(tidBin);
        -- if (j = -1) then
        --     j := 0;
        --     for i in L..j+1 loop
        --         -- receive Ri
        --         T(toggle(TidBin, i)).Res_R(Ri);
        --     end loop;
        --
        --     if (j > 0) then
        --         -- send Ri
        --         accept Res_R(R: out Vector) do
        --             R(1..?H) := Ri(1..?H);
        --         end Res_R;
        --     end if;
        --
        --     -- output data
        --     if (tid = 1) then
        --         if (N < 17)
        --             OutputVector(R);
        --         end if;
        --     end if;

            -- Put_Line("T" & Integer'Image(tid) & " finished");
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

