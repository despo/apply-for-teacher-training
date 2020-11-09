import accessibleAutocomplete from "accessible-autocomplete";
import {accessibleAutocompleteFromSource} from "./helpers";

const ids = [
  {
    id: "candidate-interface-gcse-grade-form-grade-field",
    autocompleteId: "gcse-grade-autocomplete",
  },
  {
    id: "candidate-interface-gcse-grade-form-grade-error-field",
    autocompleteId: "gcse-grade-error-autocomplete",
  },
  {
    id: "candidate-interface-science-gcse-grade-form-single-award-grade-field",
    autocompleteId: "gcse-single-grade-autocomplete",
  },
  {
    id: "candidate-interface-science-gcse-grade-form-single-award-grade-field-error",
    autocompleteId: "gcse-single-grade-autocomplete",
  },
  {
    id: "candidate-interface-science-gcse-grade-form-double-award-grade-field",
    autocompleteId: "gcse-double-grade-autocomplete",
  },
  {
    id: "candidate-interface-science-gcse-grade-form-double-award-grade-field-error",
    autocompleteId: "gcse-double-grade-autocomplete",
  },
  {
    id: "candidate-interface-science-gcse-grade-form-biology-grade-field",
    autocompleteId: "gcse-biology-grade-autocomplete",
  },
  {
    id: "candidate-interface-science-gcse-grade-form-biology-grade-field-error",
    autocompleteId: "gcse-biology-grade-autocomplete",
  },
  {
    id: "candidate-interface-science-gcse-grade-form-physics-grade-field",
    autocompleteId: "gcse-physics-grade-autocomplete",
  },
  {
    id: "candidate-interface-science-gcse-grade-form-physics-grade-field-error",
    autocompleteId: "gcse-physics-grade-autocomplete",
  },
  {
    id: "candidate-interface-science-gcse-grade-form-chemistry-grade-field",
    autocompleteId: "gcse-chemistry-grade-autocomplete",
  },
  {
    id: "candidate-interface-science-gcse-grade-form-chemistry-grade-field-error",
    autocompleteId: "gcse-chemistry-grade-autocomplete",
  },
];

const initGcseGradeAutocomplete = () => {
  try {
    ids.forEach( ids  => {
      const input = document.getElementById(ids.id);
      if (!input) return;

      const container = document.getElementById(ids.autocompleteId);
      if (!container) return;

      accessibleAutocompleteFromSource(input, container);
    });
  } catch (err) {
    console.error("Could not enhance GCSE grade input:", err);
  }
};

export default initGcseGradeAutocomplete;
