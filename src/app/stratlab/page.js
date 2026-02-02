import Sidebar from "@/components/Sidebar/Sidebar";
import Dashboard from "@/components/Dashboard/Dashboard";
import Notes from "@/components/Notes/Notes";

export default function Home() {
  return (
    <div className="app-layout">
      <Sidebar />

      <div className="main-content">
        <Dashboard />
        <Notes />
      </div>
    </div>
  );
}