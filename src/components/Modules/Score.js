"use client";

export default function Score({ id, onRemove }) {
  return (
    <div>
      <button onClick={() => onRemove(id)}>x</button>
      <div>Score Module</div>
    </div>
  );
}
