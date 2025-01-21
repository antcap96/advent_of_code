module [
    Point2D,
    add,
    sub,
    mul,
    rotate90_around_origin,
    rotate180_around_origin,
    rotate270_around_origin,
    rotate_around_origin,
    modulo,
]

Point2D a : (Num a, Num a)

add : Point2D a, Point2D a -> Point2D a
add = |(x1, y1), (x2, y2)| (x1 + x2, y1 + y2)

sub : Point2D a, Point2D a -> Point2D a
sub = |(x1, y1), (x2, y2)| (x1 - x2, y1 - y2)

mul : Point2D a, Num a -> Point2D a
mul = |(x, y), factor| (x * factor, y * factor)

rotate90_around_origin : Point2D a -> Point2D a
rotate90_around_origin = |(x, y)| (y, -x)

rotate180_around_origin : Point2D a -> Point2D a
rotate180_around_origin = |position| rotate90_around_origin(rotate90_around_origin(position))

rotate270_around_origin : Point2D a -> Point2D a
rotate270_around_origin = |position| rotate90_around_origin(rotate180_around_origin(position))

## TODO: Should probably do remainder
rotate_around_origin : Point2D a, Int * -> Point2D a
rotate_around_origin = |point, amount|
    when amount is
        1 -> rotate90_around_origin(point)
        2 -> rotate180_around_origin(point)
        3 -> rotate270_around_origin(point)
        _ -> point

modulo : Point2D a -> Num a
modulo = |(x, y)| Num.abs(x) + Num.abs(y)
