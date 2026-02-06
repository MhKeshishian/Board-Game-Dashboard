"use client";

export default function Dice({ id, onRemove }) {
  return (
    <div>
      <button onClick={() => onRemove(id)}>x</button>
      <div>Dice Module</div>
    </div>
  );
}
