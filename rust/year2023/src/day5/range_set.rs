use std::ops::Range;

#[derive(Debug, Default, Clone)]
pub struct RangeSet {
    pub ranges: Vec<Range<i64>>,
}

impl RangeSet {
    pub fn is_empty(&self) -> bool {
        self.ranges.is_empty()
    }

    pub fn intersect(&self, other: &Range<i64>) -> RangeSet {
        RangeSet {
            ranges: self
                .ranges
                .iter()
                .filter_map(|range| intersect(range, other))
                .collect(),
        }
    }

    pub fn diff(&self, other: &RangeSet) -> RangeSet {
        other
            .ranges
            .iter()
            .fold(self.clone(), |range_set, other| range_set.diff_range(other))
    }

    pub fn diff_range(&self, other: &Range<i64>) -> RangeSet {
        let mut ranges = Vec::new();

        for range in &self.ranges {
            // Non overlapping
            if range.start >= other.end || range.end <= other.start {
                ranges.push(range.clone());
                continue;
            }
            match (range.start >= other.start, range.end <= other.end) {
                // Contained
                (true, true) => {}
                // Contains
                (false, false) => {
                    ranges.push(range.start..other.start);
                    ranges.push(other.end..range.end);
                }
                // Semi-overlap start
                (true, false) => {
                    ranges.push(other.end..range.end);
                }
                // Semi-overlap end
                (false, true) => {
                    ranges.push(range.start..other.start);
                }
            }
        }
        RangeSet { ranges }
    }

    pub fn union(&self, other: &RangeSet) -> RangeSet {
        let mut output = self.diff(other);

        // FIXME: this should combine consecutive ranges to keep the number
        // of ranges to a minimum
        output.ranges.extend(other.ranges.clone());

        output
    }

    pub fn shift(mut self, delta: i64) -> RangeSet {
        self.ranges
            .iter_mut()
            .for_each(|range| *range = (range.start + delta)..(range.end + delta));

        self
    }
}

fn intersect(a: &Range<i64>, b: &Range<i64>) -> Option<Range<i64>> {
    let start = a.start.max(b.start);
    let end = a.end.min(b.end);
    (start < end).then(|| start..end)
}
