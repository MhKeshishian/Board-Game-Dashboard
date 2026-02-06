"use client";

export default function ModuleItem({ moduleId, label, icon }) {
  function handleDragStart(e) {
    e.dataTransfer.setData("text/plain", moduleId);
    e.dataTransfer.effectAllowed = "move";
  }

  return (
    <div className="module-item" draggable={true} onDragStart={handleDragStart}>
      <img className="module-icon" src={icon} alt={label} />
      <div className="module-label">{label}</div>
    </div>
  );
}
