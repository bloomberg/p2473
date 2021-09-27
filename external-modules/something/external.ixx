export module something.external;

import transitive.dependency;
import something.prebuilt;

void something_external(void) {
     transitive_dependency();
}
