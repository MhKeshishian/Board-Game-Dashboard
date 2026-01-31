"use client";

export default function WidgetItem({ name }) {
  const handleDragStart = (e) => {
    e.dataTransfer.setData("text/plain", name);
    e.dataTransfer.effectAllowed = "move";
  };

  return <div className="widget-item" draggable={true} onDragStart={handleDragStart}>{name}</div>;
}
