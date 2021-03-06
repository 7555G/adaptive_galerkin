module types

    ! Define Data Types for Nodes and Elements
    
    type fem_node
        real, allocatable :: x(:)
        real, allocatable :: y(:)
        integer, allocatable :: stat(:) ! 0: free, 1: prescribed
        real, allocatable :: P(:) ! nodal prescribed dimensionless pressure
        real, allocatable :: H(:) ! nodal dimensionless height
    end type fem_node

    type fem_element
        integer, allocatable :: node(:, :) ! nodes of element
        real, allocatable :: q(:, :) ! flow on side
        real, allocatable :: He(:) ! average H of element
        real, allocatable :: c(:) ! parameter c of element
    end type fem_element

    ! Interface the two types of "extend" subroutines
    interface extend
        module procedure ExtendArray_real, ExtendArray_int, &
                         ExtendMatrix_real, ExtendMatrix_int
    end interface extend

    ! Interface the two types of "order" function
    interface order
        module procedure order_real, order_int
    end interface order

contains

    ! subroutine to allocate nodes
    subroutine alloc_node(node, n)

        implicit none

        integer, intent(in) :: n
        type(fem_node)      :: node

        allocate(node%x(n))
        allocate(node%y(n))
        allocate(node%stat(n))
        allocate(node%P(n))
        allocate(node%H(n))

    end subroutine alloc_node


    ! subroutine to deallocate nodes
    subroutine dealloc_node(node)

        implicit none

        type(fem_node) :: node

        deallocate(node%x)
        deallocate(node%y)
        deallocate(node%stat)
        deallocate(node%P)
        deallocate(node%H)

    end subroutine dealloc_node


    ! subroutine to allocate elements
    subroutine alloc_elem(element, n, elem_nodes)

        implicit none

        integer, intent(in) :: n, elem_nodes
        type(fem_element)   :: element

        allocate(element%node(n, elem_nodes))
        allocate(element%q(n, elem_nodes))
        allocate(element%He(n))
        allocate(element%c(n))

    end subroutine alloc_elem


    ! subroutine to deallocate nodes
    subroutine dealloc_elem(element)

        implicit none

        type(fem_element) :: element

        deallocate(element%node)
        deallocate(element%q)
        deallocate(element%He)
        deallocate(element%c)

    end subroutine dealloc_elem


    ! Subroutine to add "len" number of rows after "loc" location
    ! in an array
    subroutine ExtendArray_real(A, loc, len)

        implicit none

        real, allocatable   :: A(:), temp(:)
        integer             :: n
        integer, intent(in) :: loc, len

        n = size(A)
        allocate(temp(n))


        if (loc > n .or. loc < 0) then
            print *, "Error: cannot extend matrix on given location"
            return
        end if

        if (len + loc < 0) then
            print *, "Error: cannot extend matrix by given length"
            return
        end if


        temp = A

        deallocate(A)
        allocate(A(n + len))

        if (loc > n + len) then
            A(:(n + len)) = temp(:(n + len))
        else if (loc == n + len) then
            A(:loc) = temp(:loc)
            A((loc + len + 1):) = temp((loc + 1):)
        else 
            A(:loc) = temp(:loc)
            A((loc + len + 1):) = temp((loc + 1):)
            A((loc + 1):(loc + len)) = 0
        end if

        deallocate(temp)

    end subroutine ExtendArray_real


    ! Same for integer array
    subroutine ExtendArray_int(A, loc, len)

        implicit none

        integer, allocatable :: A(:), temp(:)
        integer              :: n
        integer, intent(in)  :: loc, len

        n = size(A)
        allocate(temp(n))


        if (loc > n .or. loc < 0) then
            print *, "Error: cannot extend matrix on given location"
            return
        end if

        if (len + loc < 0) then
            print *, "Error: cannot extend matrix by given length"
            return
        end if


        temp = A

        deallocate(A)
        allocate(A(n + len))

        if (loc > n + len) then
            A(:(n + len)) = temp(:(n + len))
        else if (loc == n + len) then
            A(:loc) = temp(:loc)
            A((loc + len + 1):) = temp((loc + 1):)
        else 
            A(:loc) = temp(:loc)
            A((loc + len + 1):) = temp((loc + 1):)
            A((loc + 1):(loc + len)) = 0
        end if

        deallocate(temp)

    end subroutine ExtendArray_int


    ! Subroutine to add "len" number of rows after "loc" location
    ! in a matrix
    subroutine ExtendMatrix_real(A, loc, len)

        implicit none

        real, allocatable   :: A(:, :), temp(:, :)
        integer             :: n, m
        integer, intent(in) :: loc, len

        n = size(A, dim = 1)
        m = size(A, dim = 2)
        allocate(temp(n, m))


        if (loc > n .or. loc < 0) then
            print *, "Error: cannot extend matrix on given location"
            return
        end if

        if (len + loc < 0) then
            print *, "Error: cannot extend matrix by given length"
            return
        end if


        temp = A

        deallocate(A)
        allocate(A((n + len), m))

        if (loc > n + len) then
            A(:(n + len), :) = temp(:(n + len), :)
        else if (loc == n + len) then
            A(:loc, :) = temp(:loc, :)
            A((loc + len + 1):, :) = temp((loc + 1):, :)
        else 
            A(:loc, :) = temp(:loc, :)
            A((loc + len + 1):, :) = temp((loc + 1):, :)
            A((loc + 1):(loc + len), :) = 0
        end if

        deallocate(temp)

    end subroutine ExtendMatrix_real


    ! Same for integer matrix
    subroutine ExtendMatrix_int(A, loc, len)

        implicit none

        integer, allocatable :: A(:, :), temp(:, :)
        integer              :: n, m
        integer, intent(in)  :: loc, len

        n = size(A, dim = 1)
        m = size(A, dim = 2)
        allocate(temp(n, m))


        if (loc > n .or. loc < 0) then
            print *, "Error: cannot extend matrix on given location"
            return
        end if

        if (len + loc < 0) then
            print *, "Error: cannot extend matrix by given length"
            return
        end if


        temp = A

        deallocate(A)
        allocate(A((n + len), m))

        if (loc > n + len) then
            A(:(n + len), :) = temp(:(n + len), :)
        else if (loc == n + len) then
            A(:loc, :) = temp(:loc, :)
            A((loc + len + 1):, :) = temp((loc + 1):, :)
        else 
            A(:loc, :) = temp(:loc, :)
            A((loc + len + 1):, :) = temp((loc + 1):, :)
            A((loc + 1):(loc + len), :) = 0
        end if

        deallocate(temp)

    end subroutine ExtendMatrix_int


    ! Function which exoprts the order of ascending 
    ! elements of real array A
    pure function order_real(A) result(order)

        implicit none

        real, intent(in)     :: A(:)
        real                 :: CurMin
        integer, allocatable :: order(:)
        integer              :: n, i, j

        allocate(order(size(A)))

        CurMin = minval(A)
        j = 0

        order = 0
        do n = 1, size(A, 1)
            do i = 1, size(A, 1)
                if (A(i) == CurMin) then
                    j = j + 1
                    order(j) = i
                end if
            end do
            CurMin = minval(A, mask = (A > CurMin))
        end do
        
    end function order_real


    ! Same for integer array A
    pure function order_int(A) result(order)

        implicit none

        integer, intent(in)  :: A(:)
        integer              :: CurMin
        integer, allocatable :: order(:)
        integer              :: n, i, j

        allocate(order(size(A)))

        CurMin = minval(A)
        j = 0

        order = 0
        do n = 1, size(A, 1)
            do i = 1, size(A, 1)
                if (A(i) == CurMin) then
                    j = j + 1
                    order(j) = i
                end if
            end do
            CurMin = minval(A, mask = (A > CurMin))
        end do
        
    end function order_int

end module types
