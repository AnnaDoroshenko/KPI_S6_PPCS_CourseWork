with Text_IO, Ada.Integer_Text_IO;
use text_IO, Ada.Integer_Text_IO;

----- Body of package Data -----

package body data is

    procedure FillVectorWithOnes(vA : out Vector) is
    begin
        for i in 1..N loop
            vA(i) := 1;
        end loop;
    end FillVectorWithOnes;

    procedure FillMatrixWithOnes(MA : out Matrix) is
    begin
        for i in 1..N loop
            for j in 1..N loop
                MA(i)(j) := 1;
            end loop;
        end loop;
    end FillMatrixWithOnes;

    procedure OutputVector (VA : in Vector) is
    begin
        for i in 1..N loop
            Put(VA(i));
        end loop;
    end OutputVector;

    -------------------------------------------------------
    function getVertexNumber(tid: in Integer) return Vertex is
        BinNum: Vertex;
        id: Integer;
    begin
        id := tid - 1;
        for i in POWER..1 loop
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

        for i in POWER..1 loop
            if (tidBin(i) = waitingFor) then
                return i;
            end if;
        end loop;

        return -1;
    end getPositionOfJ;

    function PositionOfRightmost1(tidBin: in Vertex) return Integer is
        waitingFor: Integer;
    begin	
        if (isDirect(tidBin)) then
            waitingFor := 1;
        else
            waitingFor := 0;
        end if;

        for i in POWER..1 loop
            if (TidBin(i) = waitingFor) then
                return i;
            end if;
        end loop;

        return -1;
    end PositionOfRightmost1;

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
        return 2**(j-1);
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
