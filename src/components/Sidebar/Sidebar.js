"use client";

import WidgetItem from "./WidgetItem";

export default function Sidebar() {
  return (
    <div className="sidebar">
      <WidgetItem name="Score" />
      <WidgetItem name="Command Points" />
      <WidgetItem name="Turn Order" />
    </div>
  );
}
