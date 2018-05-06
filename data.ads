generic
    POWER: Integer;
    N: Integer;
    H: Integer;

package data is

    type Vertex is array (1..POWER) of Integer;
    type Vector is array (Integer range<>) of Integer;
    type Matrix is array (Integer range<>) of Vector(1..N);

    procedure FillVectorWithOnes(V : access Vector);
    procedure FillMatrixWithOnes(M : access Matrix);
    procedure OutputVector (V : access Vector; size: Integer);
    procedure OutputMatrix (M : access Matrix; size: Integer);

    function getVertexNumber(tid: in Integer) return Vertex;
    function isDirect(tidBin: in Vertex) return Boolean;
    function getPositionOfJ(tidBin: in Vertex) return Integer;
    function getDataSize(tidBin: in Vertex; directData: Boolean) return Integer;
    function getPositionOfRightmost(tidBin: in Vertex; digit: in Integer) return Integer;
    function toggle(tidBin: in out Vertex; index: in Integer) return Vertex;
    function getWeight(j: in Integer) return Integer;

    -- function SearchMinElemOfVector(A: in Vector) return Integer;
    -- function SearchTotalMin(a, b: in Integer) return Integer;
    -- function MultMatrices(MA, MB: in Matrix) return Matrix;
    -- function MultVectorMatrix(VA: in Vector; MA :in Matrix) return Vector;
    -- function MultScalarVector(scalar: in Integer; VA: in Vector) return Vector;
    -- procedure AddVectors(VR: out Vector; VA, VB: in Vector);

end data;
