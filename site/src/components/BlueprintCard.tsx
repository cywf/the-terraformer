interface BlueprintCardProps {
  title: string;
  description: string;
  tags: string[];
  detailsUrl: string;
}

export default function BlueprintCard({ title, description, tags, detailsUrl }: BlueprintCardProps) {
  return (
    <div className="blueprint-card">
      <div className="card-body">
        <h3 className="card-title text-lg">{title}</h3>
        <p className="text-sm opacity-80">{description}</p>
        <div className="flex flex-wrap gap-2 my-2">
          {tags.map((tag) => (
            <span key={tag} className="badge badge-primary badge-sm">
              {tag}
            </span>
          ))}
        </div>
        <div className="card-actions justify-end mt-4">
          <a href={detailsUrl} className="btn btn-primary btn-sm">
            View Details
          </a>
        </div>
      </div>
    </div>
  );
}
