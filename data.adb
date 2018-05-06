with Text_IO, Ada.Integer_Text_IO;
use text_IO, Ada.Integer_Text_IO;

----- Body of package Data -----

package body data is

    procedure FillVectorWithOnes(V : access Vector) is
    begin
        for i in 1..N loop
            V(i) := i;
        end loop;
    end FillVectorWithOnes;

    procedure FillMatrixWithOnes(M : access Matrix) is
    begin
        for i in 1..N loop
            for j in 1..N loop
                M(i)(j) := i;
            end loop;
        end loop;
    end FillMatrixWithOnes;

    procedure OutputVector (V : access Vector; size: Integer) is
    begin
        for i in 1..size loop
            Put(V(i));
        end loop;
        Put_Line("");
    end OutputVector;

    procedure OutputMatrix (M : access Matrix; size: Integer) is
    begin
        for i in 1..size loop
            for j in 1..N loop
                Put(M(i)(j));
            end loop;
            Put_Line("");
        end loop;
    end OutputMatrix;

    -------------------------------------------------------
    function getVertexNumber(tid: in Integer) return Vertex is
        BinNum: Vertex;
        id: Integer;
    begin
        id := tid - 1;
        for i in reverse 1..POWER loop
            BinNum(i) := id rem 2;
            id := id / 2;
        end loop;
        return BinNum;
    end getVertexNumber;

    function isDirect(tidBin: in Vertex) return Boolean is
    begin
        if (tidBin(POWER) = 0) then
            return True;
        else
            return False;
        end if;
    end isDirect;

    function getPositionOfJ(tidBin: in Vertex) return Integer is
        waitingFor: Integer;
    begin
        if (isDirect(tidBin)) then
            waitingFor := 1;
        else
            waitingFor := 0;
        end if;

        for i in reverse 1..POWER loop
            if (tidBin(i) = waitingFor) then
                return i;
            end if;
        end loop;

        return 0;
    end getPositionOfJ;

    function getDataSize(tidBin: in Vertex; directData: Boolean) return Integer is
        digit: Integer;
    begin
        if directData then
            digit := 1;
        else
            digit := 0;
        end if;

        return getWeight(getPositionOfRightmost(tidBin, digit));
    end;

    function getPositionOfRightmost(tidBin: in Vertex; digit: in Integer) return Integer is
        waitingFor: Integer;
    begin
        for i in reverse 1..POWER loop
            if (tidBin(i) = digit) then
                return i;
            end if;
        end loop;

        return 0;
    end getPositionOfRightmost;

    -- uncheckd
    function toggle(tidBin: in out Vertex; index: in Integer) return Vertex is
    begin
        if (tidBin(index) = 1) then
            tidBin(index) := 0;
        else
            tidBin(index) := 1;
        end if;
        return tidBin;
    end toggle;

    function getWeight(j: in Integer) return Integer is
    begin
        return 2**(POWER - j);
    end GetWeight;

    -- Operations with data --
    -- function SearchMinElemOfVector(A: in Vector) return Integer is
    --     minElem: Integer := A(1);
    -- begin
    --     for i in 1..h loop
    --         if A(i) < minElem then
    --             minElem := A(i);
    --         end if;
    --     end loop;
    --     return minElem;
    -- end SearchMinElemOfVector;
    --
    -- function SearchTotalMin(a, b: in Integer) return Integer is
    --     min: Integer := a;
    -- begin
    --     if b < a then
    --         min := b;
    --     end if;
    --     return min;
    -- end SearchTotalMin;
    --
    -- function MultMatrices(MA, MB: in Matrix) return Matrix is
    --     mRes: MatrixN;
    -- begin
    --     for i in 1..H loop
    --         for j in 1..N loop
    --             mRes(i)(j) := 0;
    --             for k in 1..N loop
    --                 mRes(i)(j) := mRes(i)(j) + MA (i)(k) * MB (k)(j);
    --             end loop;
    --         end loop;
    --     end loop;
    --     return mRes;
    -- end MultMatrices;
    --
    -- function MultVectorMatrix(VA: in Vector; MA :in Matrix) return Vector is
    --     ResVector : Vector;
    -- begin
    --     for i in H loop
    --         ResVector(i) := 0;
    --         for j in 1..N loop
    --             ResVector(i) := ResVector(i) + VA(j) * MA(j)(i);
    --         end loop;
    --     end loop;
    --     return ResVector;
    -- end MultVectorMatrix;
    --
    -- function MultScalarVector(scalar: in Integer; VA: in Vector) return Vector is
    --     resVector: VectorN;
    -- begin
    --     for i in 1..H loop
    --         resVector(i) := scalar * VA(i);
    --     end loop;
    --     return resVector;
    -- end MultScalarVector;
    --
    -- procedure AddVectors(VR: out Vector; VA, VB: in Vector) is
    -- begin
    --     for i in 1..H loop
    --         VR := VA(i) + VB(i);
    --     end loop;
    -- end AddVectors;

end data;
