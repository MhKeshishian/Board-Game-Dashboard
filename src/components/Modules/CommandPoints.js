"use client";

export default function CommandPoints({ id, onRemove }) {
    return (
        <div>
        <button onClick={() => onRemove(id)}>x</button>
        <div>Command Points Module</div>
        </div>
    );
}
