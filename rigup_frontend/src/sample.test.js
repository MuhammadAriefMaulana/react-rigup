const sum = require('./sample');

test('adds 1 + 2 to equal 3', () => {
  expect(sum(1, 2)).toBe(3);
});

test('adds 1 + 4 to equal 5', () => {
  expect(sum(1, 4)).toBe(5)
});

test('add 1 + 5 to equal 6', ()=>{
  expect(sum(1,5)).toBe(6)
})

test('add 2 + 3 to equal 5', ()=>{
  expect(sum(2,3)).toBe(0)
})