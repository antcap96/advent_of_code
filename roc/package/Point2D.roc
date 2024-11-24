module [
    Point2D,
    add,
    sub,
    mul,
    rotate90AroundOrigin,
    rotate180AroundOrigin,
    rotate270AroundOrigin,
    rotateAroundOrigin,
    modulo,
]

Point2D a : (Num a, Num a)

add : Point2D a, Point2D a -> Point2D a
add = \(x1, y1), (x2, y2) -> (x1 + x2, y1 + y2)

sub : Point2D a, Point2D a -> Point2D a
sub = \(x1, y1), (x2, y2) -> (x1 - x2, y1 - y2)

mul : Point2D a, Num a -> Point2D a
mul = \(x, y), factor -> (x * factor, y * factor)

rotate90AroundOrigin : Point2D a -> Point2D a
rotate90AroundOrigin = \(x, y) -> (y, -x)

rotate180AroundOrigin : Point2D a -> Point2D a
rotate180AroundOrigin = \position -> rotate90AroundOrigin (rotate90AroundOrigin position)

rotate270AroundOrigin : Point2D a -> Point2D a
rotate270AroundOrigin = \position -> rotate90AroundOrigin (rotate180AroundOrigin position)

## TODO: Should probably do remainder
rotateAroundOrigin : Point2D a, Int * -> Point2D a
rotateAroundOrigin = \point, amount ->
    when amount is
        1 -> rotate90AroundOrigin point
        2 -> rotate180AroundOrigin point
        3 -> rotate270AroundOrigin point
        _ -> point

modulo : Point2D a -> Num a
modulo = \(x,y) -> Num.abs x + Num.abs y
