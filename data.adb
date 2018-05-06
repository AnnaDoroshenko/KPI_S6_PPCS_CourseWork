with Text_IO, Ada.Integer_Text_IO;
use text_IO, Ada.Integer_Text_IO;

----- Body of package Data -----

package body data is

    procedure FillVectorWithOnes(V : access Vector) is
    begin
        for i in 1..N loop
            V(i) := 1;
        end loop;
    end FillVectorWithOnes;

    procedure FillMatrixWithOnes(M : access Matrix) is
    begin
        for i in 1..N loop
            for j in 1..N loop
                M(i)(j) := 1;
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

    function getTid(tidBin: in Vertex) return Integer is
        tid: Integer := 1;
        mult: Integer := 1;
    begin
        for i in reverse 1..POWER loop
            tid := tid + tidBin(i) * mult;
            mult := mult * 2;
        end loop;

        return tid;
    end getTid;

    function isDirect(tidBin: in Vertex) return Boolean is
    begin
        if (tidBin(POWER) = 0) then
            return True;
        else
            return False;
        end if;
    end isDirect;

    function getPositionOfJ(tidBin: in Vertex) return Integer is
        searchingFor: Integer;
    begin
        if (isDirect(tidBin)) then
            searchingFor := 1;
        else
            searchingFor := 0;
        end if;

        return getPositionOfRightmost(tidBin, searchingFor);
    end getPositionOfJ;

    function getDataSizeInHs(tidBin: in Vertex; directData: Boolean) return Integer is
        digit: Integer;
    begin
        if directData then
            digit := 1;
        else
            digit := 0;
        end if;

        return getWeight(getPositionOfRightmost(tidBin, digit));
    end getDataSizeInHs;

    function getPositionOfRightmost(tidBin: in Vertex; digit: in Integer) return Integer is
    begin
        for i in reverse 1..POWER loop
            if (tidBin(i) = digit) then
                return i;
            end if;
        end loop;

        return 0;
    end getPositionOfRightmost;

    function toggle(tidBin: in Vertex; index: in Integer) return Vertex is
        newTidBin: Vertex;
    begin
        newTidBin := tidBin;
        if (newTidBin(index) = 1) then
            newTidBin(index) := 0;
        else
            newTidBin(index) := 1;
        end if;

        return newTidBin;
    end toggle;

    function getWeight(j: in Integer) return Integer is
    begin
        return 2**(POWER - j);
    end GetWeight;

    -- Operations with data --
    function SearchMinElemOfVector(A: access Vector) return Integer is
        minElem: Integer := A(1);
    begin
        for i in 1..H loop
            if A(i) < minElem then
                minElem := A(i);
            end if;
        end loop;
        return minElem;
    end SearchMinElemOfVector;

    function SearchTotalMin(a, b: in Integer) return Integer is
        min: Integer := a;
    begin
        if b < a then
            min := b;
        end if;
        return min;
    end SearchTotalMin;

end data;
