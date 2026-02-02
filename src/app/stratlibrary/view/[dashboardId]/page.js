export default async function ViewSharedDashboardPage({ params }) {
  const { dashboardId } = await params;

  return <div>View shared dashboard placeholder (Route: /stratlibrary/view/{dashboardId})</div>;
}
