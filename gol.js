const Cell = (x, y) => ({ x, y });
const getNeighbors = cell => {
  const neighbors = [];
  for (let x = -1; x <= 1; x++) {
    for (let y = -1; y <= 1; y++) {
      if (x === 0 && y === 0) continue;
      neighbors.push(Cell(x + cell.x, y + cell.y));
    }
  }

  return neighbors;
};

const compareCells = (a, b) => a.x === b.x && a.y === b.y;

const uniq = (arr, comparator) =>
  arr.reduce((acc, val) => {
    if (!acc.some(x => comparator(x, val))) {
      acc.push(val);
    }

    return acc;
  }, []);

const tick = (world, rules) => {
  const allCells = rules.reduce((acc, rule) => acc.concat(rule(world)), []);
  return uniq(allCells, compareCells);
};

const twoOrThreeCellsLive = world =>
  world.reduce((acc, cell) => {
    const neighbors = getNeighbors(cell);
    const neighborCount = world.filter(c =>
      neighbors.some(n => compareCells(c, n))
    ).length;
    if (neighborCount === 2 || neighborCount === 3) {
      acc.push(cell);
    }
    return acc;
  }, []);

const threeNeighboringCellsLive = world =>
  world.reduce((acc, cell) => {
    const neighbors = getNeighbors(cell);
    const live = neighbors.filter(
      nc =>
        getNeighbors(nc).filter(x => world.some(wc => compareCells(x, wc)))
          .length === 3
    );
    return acc.concat(live);
  }, []);

// --------------- TESTS
const assert = require("chai").assert;

const oneLiveCellRule = world => [Cell(2, 2)];

describe("game of life", () => {
  it("returns an empty world when given an empty world and no rules", () => {
    const world = [];
    const tickedWorld = tick(world, []);
    assert.deepEqual(tickedWorld, []);
  });

  it("returns a world with one cell when given a rule that creates one cell", () => {
    const world = [],
      tickedWorld = tick(world, [oneLiveCellRule]);

    assert.deepEqual(tickedWorld, [Cell(2, 2)]);
  });

  it("returns a world with one cell when two rules create the same cell", () => {
    const tickedWorld = tick([], [oneLiveCellRule, oneLiveCellRule]);
    assert.deepEqual(tickedWorld, [Cell(2, 2)]);
  });

  it("plays a blinker", () => {
    const world = [Cell(1, 1), Cell(1, 2), Cell(1, 3)],
      tickedWorld = tick(world, [
        twoOrThreeCellsLive,
        threeNeighboringCellsLive
      ]);
    assert.deepInclude(tickedWorld, Cell(0, 2));
    assert.deepInclude(tickedWorld, Cell(1, 2));
    assert.deepInclude(tickedWorld, Cell(2, 2));
    assert.equal(tickedWorld.length, 3);
  });
});

describe("compareCells", () => {
  it("returns true for equal cells", () => {
    assert.isTrue(compareCells(Cell(1, 1), Cell(1, 1)));
  });

  it("returns false for unequal cells", () => {
    assert.isFalse(compareCells(Cell(1, 1), Cell(1, 2)));
  });
});

describe("twoOrThreeCellsLive", () => {
  it("keeps a cell alive if it has two live neighbours", () => {
    const world = [Cell(1, 1), Cell(1, 2), Cell(1, 3)],
      tickedWorld = twoOrThreeCellsLive(world);

    assert.deepEqual(tickedWorld, [Cell(1, 2)]);
  });

  it("keeps a cell alive if it has three live neighbours", () => {
    const world = [Cell(1, 1), Cell(1, 2), Cell(1, 3), Cell(2, 2)],
      tickedWorld = twoOrThreeCellsLive(world);

    assert.deepEqual(tickedWorld, world);
  });
});

describe("threeNeighboringCellsLive", () => {
  it("brings a cell to life if it has three live neighbors", () => {
    const world = [Cell(1, 1), Cell(1, 2), Cell(1, 3)],
      tickedWorld = threeNeighboringCellsLive(world);

    assert.deepEqual(uniq(tickedWorld, compareCells), [Cell(0, 2), Cell(2, 2)]);
  });
});
