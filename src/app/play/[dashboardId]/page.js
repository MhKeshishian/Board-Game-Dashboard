export default async function PlayModePage({ params }) {
  const { dashboardId } = await params;

  return <div>Play mode placeholder (Route: /play/{dashboardId})</div>;
}
