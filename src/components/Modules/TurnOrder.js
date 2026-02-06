"use client";

export default function TurnOrder({ id, onRemove }) {
  return (
    <div>
      <button onClick={() => onRemove(id)}>x</button>
      <div>Turn Order Module</div>
    </div>
  );
}
