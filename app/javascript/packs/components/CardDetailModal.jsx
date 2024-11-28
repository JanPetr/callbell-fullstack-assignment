import React from "react";
import { marked } from "marked";

export default function CardDetailsModal({ card, onClose }) {
  if (!card) return null;
  
  const formatDate = (date) => {
    return new Intl.DateTimeFormat("en-CA", { year: "numeric", month: "2-digit", day: "2-digit" }).format(new Date(date));
  };
  
  const sanitize = (dirty) => {
    const clean = document.createElement('div');
    clean.textContent = dirty;
    return clean.innerHTML;
  };
  
  return (
    <div className="fixed inset-0 bg-gray-800 bg-opacity-50 flex items-center justify-center">
      <div className="bg-white rounded shadow p-6 w-96">
        <h2 className="text-2xl font-bold mb-4">{card.name}</h2>
        <div className="mb-4">
          <div
            className="mt-2 text-gray-800 rounded"
            dangerouslySetInnerHTML={{
              __html: card.description
                ? marked(sanitize(card.description))
                : "<em>No description</em>",
            }}
          />
        </div>
        {card.due_date &&
          <div className="mb-4 text-right">
            <p className="mt-2 text-gray-400 text-sm italic">Due {formatDate(card.due_date)}</p>
          </div>
        }
        <div className="flex justify-end">
          <button
            onClick={onClose}
            className="px-4 py-2 bg-gray-300 text-gray-700 rounded"
          >
            Close
          </button>
        </div>
      </div>
    </div>
  );
}
